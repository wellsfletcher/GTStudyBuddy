//
//  CRNSetupView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 3/15/22.
//

import SwiftUI
import FirebaseFirestore

struct CRNSetupView: View {
  @State var crnInput: String = ""
  @State var sections: [CourseSection] = []
  
  @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
  
  @State var selectedTermId: String = "202202"
  var uid: String?
  
  @State var crnNumbers: [String]?
  
  var body: some View {
    VStack {
      //        Picker("Choose a term", selection: $selectedTermId) {
      //            ForEach(terms) { term in
      //                Text(term.id)
      //            }
      //        }
      //        .padding()
      
      
      TextField("Enter CRNs", text: $crnInput).padding()
      
      
      //        List {
      //            ForEach (self.sections) { section in
      //                let course = section.course
      //                Text(course.id)
      //            }
      //        }
      
      Button(action: {
        //            fetchTerms()
        //            fetchSections()
        storeCRN()
        crnNumbers?.append(crnInput)
      }, label: {
        Text("Add CRN")
      }).padding()
      
      if (crnNumbers != nil) {
        List {
          ForEach(crnNumbers!, id: \.self) { crnNumber in
            Text(crnNumber)
          }
        }
      }
    }
    .onAppear {
      // call function to get crn numbers
      self.fetchCRN()
    }
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
  
  func fetchSections() {
    CourseDownloader.downloadSections(termId: selectedTermId, completion: { crn2section in
      // self.crn2section = crn2section
      // self.sections = sections
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
        } else {
          self.crnNumbers = []
        }
      } else {
        print("Document does not exist")
        self.crnNumbers = []
      }
      
    }
  }
  
}

struct CRNSetupView_Previews: PreviewProvider {
  static var previews: some View {
    CRNSetupView()
  }
}
