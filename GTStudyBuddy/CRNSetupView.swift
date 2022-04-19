//
//  CRNSetupView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 3/15/22.
//

import SwiftUI
import FirebaseFirestore

struct CRNSetupView: View {
    @EnvironmentObject var session: SessionStore
    
    @State var crnInput: String = ""
    @State var sections: [CourseSection] = []
    
    @State var terms: [Term] = [Term(id: "202202"), Term(id: "202108")]
    
    @State var selectedTermId: String = "202202"
    
    @State var crnNumbers: [String]?
    @State var crn2section: [String: CourseSection] = [:]
    
    @State var areCoursesLoaded = false
    @State var areTermsLoaded = false
    @State var crnInvalid = false
    @State var findingBuddies = false
    @State var buddiesFound = false
    
    @State var studybuddy2mutualsections: [User: [CourseSection]] = [:]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(
                        destination: InformationForm(),
                        label: {
                            Text("Edit profile")
                        })
                        .padding()
                    
                    
                    Picker("Choose a term", selection: $selectedTermId) {
                        ForEach(terms) { term in
                            Text(term.name)
                        }
                    }
                    .padding()
                    
                    
                    HStack {
                        Text("CRNs: ")
                        TextField("Enter CRNs", text: $crnInput).padding()}
                    .padding([.leading], 15)
                    
                    Button(
                        action: {
                            crnNumbers = crnInput.components(separatedBy: ", ")
                            for eachCRN in crnNumbers! {
                              if eachCRN.count != 5 || !eachCRN.isInt || !crn2section.keys.contains(eachCRN) {
                                    crnInvalid = true
                                }
                            }
                            if !crnInvalid {
                                storeCRN()
                                updateSections()
                            }
                        },
                        label: {
                            Text("Update CRNs") // change to "Update CRNs"
                        })
                        .alert(isPresented: $crnInvalid) {
                            Alert(
                                title: Text("CRN format incorrect"),
                                message: Text("Please ensure the CRNs are valid and add your CRNs separated by a comma and space."),
                                dismissButton: .default(Text("Ok"))
                            )
                        }
                        .padding()
                    
                    
                    Section(content: {
                        if (crnNumbers != nil) {
                            // List {
                            ForEach (self.sections) { section in
                                VStack(alignment: .leading) {
                                    let course = section.course
                                    Text(section.crn).font(.subheadline).fontWeight(.light)
                                    Text(course.id + " " + section.sectionLabel + ": " + course.longTitle).font(.headline)
                                    Text(course.description ?? "")
                                }.padding()
                            }
                        }
                    }, header: {
                        Text("Courses")
                    })
                }
                
                /*
                NavigationLink(destination: ChatsView(sections: $sections), label: {
                    Text("Chat now!")
                })
                    .disabled(!areCoursesLoaded).padding()
                 */
                NavigationLink(destination: ChatsView(sections: $sections, studybuddy2mutualsections: $studybuddy2mutualsections), isActive: $buddiesFound) {
                    Button(action: {
                    
                        findStudyBuddies(completion: { studybuddy2mutualsections in
                            print("your study buddies are: ")
                            print(studybuddy2mutualsections)
                            self.studybuddy2mutualsections = studybuddy2mutualsections
                            buddiesFound = true
                        })
                        
                    }, label: {
                        Text("Chat now!")
                    })
                }.disabled(!areCoursesLoaded || findingBuddies).padding()
            }
            .onAppear {
                fetchTerms()
                fetchSections()
                fetchCRN()
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Setup CRNs")
        }
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
        // fetch current array of CRNs
        /*
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.session.session!.uid)
        ref.getDocument() { (document, error) in
            var CRNs: [String] = []
            if let document = document, document.exists {
                let dataDescription = document.data()
                if dataDescription![selectedTermId] != nil {
                    CRNs = dataDescription![selectedTermId] as! [String]
                }
            } else {
                print("CRNs do not exist")
            }
            // return CRNs
            
        }
         */
        
        getCRNs(completion: { fetchedCRNs in
            // compare fetched array
            let localCRNs = self.crnNumbers! // this might not be updated yet
            // def need to test these parts
            let removedCRNs = fetchedCRNs.subtract(from: localCRNs)
            let addedCRNs = localCRNs.subtract(from: fetchedCRNs)
            
            // submit a call to remove them from every courseSection that they removed
            for crn in removedCRNs {
                removeUserFromCourseSection(crn)
            }
            // submit a call to add them to every course section that they added
            for crn in addedCRNs {
                addUserToCourseSection(crn)
            }
            
            // update the CRNs in Firebase
            let db = Firestore.firestore()
            let ref = db.collection("users").document(self.session.session!.uid)
            // Atomically add a new region to the "regions" array field.
            ref.updateData([
                selectedTermId: crnNumbers // FieldValue.arrayUnion([crnInput])
            ])
        })
        
        // compare fetched array with local array to determine what CRNs have been removed and what CRNs have been added
        // submit a call to remove them from every courseSection that they removed
        // submit a call to add them to every course section that they added
        // (update the CRNs in Firebase normally)

    }
    
    func addUserToCourseSection(_ crn: String) {
        let db = Firestore.firestore()
        let uid = self.session.session!.uid
        
        let courseSections = db.collection("courseSections").document(selectedTermId)
        courseSections.getDocument() { (document, error) in
            if let document = document, document.exists {
                courseSections.updateData([
                    crn: FieldValue.arrayUnion([uid])
                ])
            } else {
                db.collection("courseSections").document(selectedTermId).setData([
                    crn: FieldValue.arrayUnion([uid]),
                ])
            }
        }
    }
    
    func removeUserFromCourseSection(_ crn: String) {
        let db = Firestore.firestore()
        let uid = self.session.session!.uid
        
        let courseSections = db.collection("courseSections").document(selectedTermId)
        courseSections.getDocument() { (document, error) in
            if let document = document, document.exists {
                courseSections.updateData([
                    crn: FieldValue.arrayRemove([uid])
                ])
            } else {
                print("Could not remove the CRN. This error shouldn't happen after we do a clean wipe of the database.")
            }
        }
    }
    
    func getCRNs(completion: @escaping ([String]) -> Void = {_ in }) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.session.session!.uid)
        ref.getDocument() { (document, error) in
            var CRNs: [String] = []
            if let document = document, document.exists {
                let dataDescription = document.data()
                if dataDescription![selectedTermId] != nil {
                    CRNs = dataDescription![selectedTermId] as! [String]
                }
            } else {
                print("CRNs do not exist")
            }
            completion(CRNs)
        }
    }
    
    func findStudyBuddies(completion: @escaping ([User: [CourseSection]]) -> Void = {_ in }) {
        // [User: Relationship]
        // Relationship = {[courseSections], [messages]}
        
        var studybuddy2mutualsections: [User: [CourseSection]] = [:]
        
        // fetch the current users CRNs
        getCRNs(completion: { fetchedCRNs in
            fetchClassrooms(fetchedCRNs, completion: { classrooms in
                // this key operation may not work like I want
                for crn in classrooms.keys {
                    let courseSection = crn2section[crn] ?? CourseSection.createInvalid(crn: crn)
                    let classmates = classrooms[crn]!
                    for uid in classmates {
                        // ignore current user
                        if uid == session.session!.uid {
                            // print("skipping current user")
                            continue
                        }
                        // add the user to the map to effectively count the number of occurrences of that user
                        let classmate = User(uid: uid)
                        var mutualSections = studybuddy2mutualsections[classmate, default: []]
                        mutualSections.append(courseSection)
                        studybuddy2mutualsections[classmate] = mutualSections
                    }
                }
                
                completion(studybuddy2mutualsections)
            })
        })
        // for each of the current users's courseSections
        // fetch all the users in that courseSection
    }
    
    /**
     - Parameter classroomms: Maps CRNs to UIDs, or classes to classmates
     */
    func fetchClassrooms(_ CRNs: [String], classrooms: [String: [String]] = [:], completion: @escaping ([String: [String]]) -> Void = {_ in }) {
        if CRNs.isEmpty {
            completion(classrooms)
            return
        }
        var mutatedCRNs = CRNs
        var mutatedClassrooms = classrooms
        let crn = mutatedCRNs.removeLast()
        fetchClassmates(crn, completion: { classmates in
            mutatedClassrooms[crn] = classmates
            fetchClassrooms(mutatedCRNs, classrooms: mutatedClassrooms, completion: completion)
        })
    }
    
    func fetchClassmates(_ crn: String, completion: @escaping ([String]) -> Void = {_ in }) {
        let db = Firestore.firestore()
        let ref = db.collection("courseSections").document(selectedTermId)
        ref.getDocument() { (document, error) in
            var users: [String] = []
            if let document = document, document.exists {
                let dataDescription = document.data()
                if dataDescription![crn] != nil {
                    users = dataDescription![crn] as! [String]
                }
            } else {
                print("No users in that class.")
            }
            completion(users)
        }
        // let users: [User] = []
        // completion(users)
    }
    
    func createChats(completion: @escaping ([String]) -> Void = {_ in }) {
        
    }
    
    func fetchCRN() { // completion: @escaping ([String]) -> Void = {_ in }
        let db = Firestore.firestore()
        let ref = db.collection("users").document(self.session.session!.uid)
        ref.getDocument() { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                if dataDescription![selectedTermId] != nil {
                    self.crnNumbers = dataDescription![selectedTermId] as! [String]
                    crnInput = (crnNumbers?.joined(separator: ", "))!
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
