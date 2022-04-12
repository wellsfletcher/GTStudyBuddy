//
//  InformationForm.swift
//  GTStudyBuddy
//
//  Created by Simo on 3/30/22.
//

import SwiftUI
import FirebaseFirestore

struct InformationForm: View {
    @State var fullname: String = ""
    @State var crnString: String = ""
    @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
    @State var selectedTermId = "202202"
    @State var phoneNumber = ""
    @State var submitTapped: Bool = false
    @State var studentOrganization = ""
    
    var uid: String?
    
    var body: some View {
        ZStack {
            
            Form {
                Section("Name") {
                    TextField("Enter name", text: $fullname)
                }
                
                // I think this shouldn't exist
                Section("First Semester on Campus") {
                    Picker("Choose a term", selection: $selectedTermId) {
                        ForEach(terms) { term in
                            Text(term.name)
                        }
                    }
                }
            
                
                Section("Phone number") {
                    TextField("Enter phone number", text: $phoneNumber)
                }
                
                Section("Student organizations") {
                    TextField("Enter student organizations as a comma separated list", text: $studentOrganization)// .padding(.vertical)
                }
            }
            
            VStack {
                Spacer()
                
                Button(action:{
                    submitForm()
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
                        .onTapGesture {
                            submitTapped = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                submitTapped = false
                            }
                        }
                    
                }).ignoresSafeArea(.keyboard).padding()
            }
                
        }
         
        .onAppear{
            fetchTerms()
            print(terms)
        }.navigationTitle("Edit Profile")
    }
    
    
    
    func submitForm() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.uid!)
        
        // Atomically add a new region to the "regions" array field.
        ref.setData(["fullname": fullname, "startingTerm": selectedTermId, "CRNs": csv2list(crnString), "phoneNumber": phoneNumber, "studentOrganizations": csv2list(studentOrganization)], merge: true)
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
}

struct InformationForm_Previews: PreviewProvider {
    static var previews: some View {
        InformationForm(uid: "kKg6nsMOf8bA3U1y5HqytgMR8xn2")
    }
}
