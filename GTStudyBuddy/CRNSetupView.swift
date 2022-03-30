//
//  CRNSetupView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 3/15/22.
//

import SwiftUI
import FirebaseFirestore

struct CRNSetupView: View {
    @State var crnInput: String = "32615" // 26340, 32615, 28845
    @State var sections: [CourseSection] = []
    
    @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
    
    @State var selectedTermId: String = "202202"
    var uid: String?
    
    @State var crnNumbers: [String]?
    @State var crn2section: [String: CourseSection] = [:]
    
    @State var areCoursesLoaded = false
    @State var areTermsLoaded = false
    
    var body: some View {
            VStack {
                Picker("Choose a term", selection: $selectedTermId) {
                    ForEach(terms) { term in
                        Text(term.name)
                    }
                }
                .padding()
                
                
                TextField("Enter CRNs", text: $crnInput).padding()
                
                Button(action: {
                    storeCRN()
                    if crnNumbers != nil && !crnNumbers!.contains(crnInput) {
                        crnNumbers?.append(crnInput)
                        updateSections()
                    }
                }, label: {
                    Text("Add CRN")
                }).padding()
                
                
                if (crnNumbers != nil) {
                    List {
                        ForEach (self.sections) { section in
                            VStack(alignment: .leading) {
                                let course = section.course
                                Text(course.id + " " + section.sectionLabel + ": " + course.longTitle).font(.headline)
                                Text(course.description ?? "")
                            }.padding()
                        }
                    }
                }
            }
            .onAppear {
                fetchTerms()
                fetchSections()
                // call function to get crn numbers
                // self.fetchCRN()
        }.navigationTitle("CRN Setup")

    }
    
    func fetchTerms() {
        /*
         CourseDownloader.downloadTerms { terms in
         self.terms = terms
         }*/
        CourseDownloader.downloadTerms(completion: { terms in
            self.terms = terms
            areTermsLoaded = true
        })
    }
    
    func storeCRN() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.uid!)
        
        // Atomically add a new region to the "regions" array field.
        ref.updateData([
            "classes": FieldValue.arrayUnion([crnInput])
        ])
    }
    
    func fetchCRN() {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.uid!)
        ref.getDocument() { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                if dataDescription!["classes"] != nil {
                    self.crnNumbers = dataDescription!["classes"] as! [String]
                    
                    updateSections()
                } else {
                    self.crnNumbers = []
                }
            } else {
                print("Document does not exist")
                self.crnNumbers = []
            }
            
        }
    }
    
    func fetchSections() {
        CourseDownloader.downloadSections(termId: selectedTermId, completion: { crn2section in
            self.crn2section = crn2section
            areCoursesLoaded = true
            
            fetchCRN()
            // updateSections()
        })
    }
    
    func updateSections() {
        // self.crnNumbers! += csv2list(crnInput)
        self.sections = crns2sections(self.crnNumbers!)
    }
    
    func crns2sections(_ crns: [String]) -> [CourseSection] {
        var sections: [CourseSection] = []
        
        for crn in crns {
            if let section = crn2section[crn] {
                sections.append(section)
            }
        }
        
        return sections
    }
    
    
    func csv2list(_ csv: String) -> Array<String> {
        return csv
            .components(separatedBy: ",")
            .compactMap {
                $0.trimmingCharacters(in: .whitespaces)
            }
    }
}

struct CRNSetupView_Previews: PreviewProvider {
    static var previews: some View {
        CRNSetupView()
    }
}
