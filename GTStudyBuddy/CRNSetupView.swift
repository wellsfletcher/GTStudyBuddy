//
//  CRNSetupView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 3/15/22.
//

import SwiftUI

struct CRNSetupView: View {
    @State var crnInput: String = ""
    @State var sections: [CourseSection] = []
    
    @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
    @State var selectedTermId: String = "202202"
    
    var body: some View {
        Picker("Choose a term", selection: $selectedTermId) {
            ForEach(terms) { term in
                Text(term.id)
            }
        }.padding()
        TextField("Enter CRNs", text: $crnInput).padding()
        
        List {
            ForEach (self.sections) { section in
                let course = section.course
                Text(course.id)
            }
        }
        
        Button(action: {
            fetchTerms()
            fetchSections()
        }, label: {
            Text("Convert")
        }).padding()
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
}

struct CRNSetupView_Previews: PreviewProvider {
    static var previews: some View {
        CRNSetupView()
    }
}
