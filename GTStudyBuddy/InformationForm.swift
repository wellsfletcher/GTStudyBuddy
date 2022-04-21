//
//  InformationForm.swift
//  GTStudyBuddy
//
//  Created by Simo on 3/30/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
//import SwiftProtobuf

struct InformationForm: View {
    @EnvironmentObject var session: SessionStore
    @State var fullname: String = ""
    @State var crnString: String = ""
    @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
    @State var selectedTermId = "202202"
    @State var selectedTermName = ""
    @State var phoneNumber = ""
    @State var submitTapped: Bool = false
    @State var studentOrganization = ""
    @State var loaded = false
    @State var pickerAccessed = false
    
    private enum FocusedFields:Hashable {
        case fullname, phonenumber, studentOrganization
    }
    
    @FocusState private var focusedField: FocusedFields?
    
    var body: some View {
        VStack {
            
            Form {
                Section("Name") {
                    TextField("Enter name", text: $fullname)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                        .focused($focusedField, equals: .fullname)
                }
                
                // I think this shouldn't exist
                Section("First Semester on Campus") {
                    Picker("Choose a term", selection: $selectedTermId) {
                        ForEach(terms) { term in
                            Text(term.name)
                        }
                    }.onAppear{pickerAccessed = true}.onDisappear{pickerAccessed=false}
                }
                
                
                Section("Phone number") {
                    TextField("Enter phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .focused($focusedField, equals: .phonenumber)
                }
                
                Section("Student organizations") {
                    TextField("Enter student organizations as a comma separated list", text: $studentOrganization)// .padding(.vertical)
                        .focused($focusedField, equals: .studentOrganization)
                }
            }//end Form
            .onTapGesture {
                //dismissed keyboard when user taps outside a textfield
                endEditing()
            }
            .toolbar{
                ToolbarItem(placement: .keyboard){
                    Button("Done"){
                        focusedField = nil
                    }
                }
            }//end toolbar components
            
            VStack {
                //Spacer()
                
                Button(action:{
                    submitForm()
                    
                    submitTapped = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        submitTapped = false
                    }
                },
                       // Animation added, expand and shrink upon submit click
                       // Click now
                       label:{
                    Text("Save Changes").foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(.blue)
                        .cornerRadius(15).padding(.top)
                        .scaleEffect(submitTapped ? 1.2 : 1)
                        .animation(Animation.spring(response: 0.3, dampingFraction: 0.6), value: submitTapped)
                    
                }).ignoresSafeArea(.keyboard).padding()
            }//end v-stack
            .frame(alignment: .bottom)

        }//end z-stack
        
        .onAppear{
            print(loaded)
            fetchTerms()
            print(terms)
            
            if !loaded {
                onLoad()
            }
            
            loaded = true
        }
        .navigationTitle("Edit Profile").onDisappear{
            if pickerAccessed {
                loaded = false
            }
        }
        
    }
    // function that is called with the user taps outside a textfield to ultimately dismiss the keyboard
    private func endEditing(){
        UIApplication.shared.endEditing()
    }
    
    func submitForm() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.session.session!.uid)
        
        // Atomically add a new region to the "regions" array field.
        ref.setData(["fullname": fullname, "startingTerm": selectedTermId, "CRNs": csv2list(crnString), "phoneNumber": phoneNumber, "studentOrganizations": csv2list(studentOrganization)], merge: true)
        let user = Auth.auth().currentUser!
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = fullname
        changeRequest.commitChanges { error in
            // ...
        }
        self.session.session!.displayName = fullname
        loaded = false
    }
    
    func fetchTerms() {
        /*
         CourseDownloader.downloadTerms { terms in
         self.terms = terms
         }*/
        CourseDownloader.downloadTerms(completion: { terms in
            self.terms = [Term(id: "201808"), Term(id: "201902"), Term(id: "201905"), Term(id: "201908"), Term(id: "202002"), Term(id: "202005")] + terms
        })
    }
    
    func csv2list(_ csv: String) -> Array<String> {
        return csv
            .components(separatedBy: ",")
            .compactMap {
                $0.trimmingCharacters(in: .whitespaces)
            }
    }
    
    func onLoad() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.session.session!.uid)
        
        ref.getDocument() { (document, error) in
            if let document = document { // if there's a value in document, unwrap
                let data = document.data()
                let fetchedTerm = data!["startingTerm"] as? String ?? ""
                
                fullname = self.session.session!.displayName ?? "No full name"
                selectedTermId = fetchedTerm
                
                
                //crnString = data!["CRNs"] as? String ?? "No CRN String"
                phoneNumber = data!["phoneNumber"] as?  String ?? "no phone number"
                print("Full name: \(fullname)")
                //print("CRN: \(crnString)")
                print("phone number: \(phoneNumber)")
                let fetchedStudentOrgs =  data!["studentOrganizations"] as?  Array<String> ?? [""]
                var count = 0
                var studOrgsFetched = ""
                for org in fetchedStudentOrgs {
                    if count != fetchedStudentOrgs.count -  1 {
                        studOrgsFetched += org + ", "
                    } else {
                        studOrgsFetched += org
                        
                    }
                    count+=1
                }
                
                studentOrganization = studOrgsFetched
                
                
                
            } else {
                print("Document does not exist in cache")
            }
        }
        
        
    }
}

//UIApplication extension used with func endEditing() to dismiss the keyboard when the user taps outside the textfield
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct InformationForm_Previews: PreviewProvider {
    static var previews: some View {
        InformationForm()
    }
}
