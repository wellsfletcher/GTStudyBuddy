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
    @State var studentOrganization = ""
    
    var uid: String?
    
    var body: some View {
        VStack {
            Text("Information Form:")
                .multilineTextAlignment(.center)
            TextField("Enter your Name", text: $fullname)
                .multilineTextAlignment(.center)
            Picker("", selection: $selectedTermId) {
                ForEach(terms) { term in
                    Text(term.name)
                }
            }
            TextField("Enter CRNs comma separated", text: $crnString)
            TextField("Enter Phone Number", text: $phoneNumber)
            TextField("Enter your Student Organizations comma separated", text: $studentOrganization)
            Button(action:{
                submitForm()
            },
                   label:{
                Text("Submit Form")
            })
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(.blue)
            .cornerRadius(15)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .onAppear{
            fetchTerms()
            print(terms)
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
