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
            VStack {
               
                VStack {
                    Text("Information Form")
                        .multilineTextAlignment(.center).font(.largeTitle.bold()).position(x: 150, y: 20).frame(width: 310, height: 40, alignment: .center).padding(.vertical).ignoresSafeArea(.keyboard)
                    TextField("Enter your Name", text: $fullname)
                        .multilineTextAlignment(.center).padding(.vertical)
                    Picker("", selection: $selectedTermId) {
                        ForEach(terms) { term in
                            Text(term.name)
                        }
                    }.padding(.vertical).ignoresSafeArea(.keyboard)
                    TextField("Enter CRNs comma separated", text: $crnString).padding(.vertical)
                    TextField("Enter Phone Number", text: $phoneNumber).padding(.vertical)
                    TextField("Enter your Student Organizations comma separated", text: $studentOrganization).padding(.vertical)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineSpacing(35)
                .onAppear{
                    fetchTerms()
                    print(terms)
                }
                VStack {
                Button(action:{
                    submitForm()
                },
                    // Animation added, expand and shrink upon submit click
                    // Click now
                    label:{
                        Text("Submit Form").foregroundColor(.white)
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
                    
                }).ignoresSafeArea(.keyboard)
                }
                
                Spacer()
            
            }
        
    }
        
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
            self.terms = terms
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
