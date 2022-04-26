import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

class SessionStore: ObservableObject {
    @Published var session: User?
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen(completion: @escaping (() -> Void)) {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = User(
                    uid: user.uid,
                    email: user.email
                )
                self.getUserName()
                completion()
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
                completion()
            }
        }
    }
    
    
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping ((Bool, String?) -> Void)) {
        if password.count < 8 {
            completion(false, "Password must be at least 8 characters.")
            return
        }
        
        if password != confirmPassword {
            completion(false, "Passwords do not match.")
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    // Error: The email address is already in use by another account.
                    completion(false, "This email is already in use.")
                case .invalidEmail:
                    // Error: The email address is badly formatted.
                    completion(false, "Please enter a valid email.")
                default:
                    completion(false, "There was an error with sign up. Please try again or contact GT iOS Club.")
                }
            } else {
                let db = Firestore.firestore()
                let user = authResult!.user
                db.collection("users").document(user.uid).setData(["email": email, "fullname": name], merge: true)
                completion(true, nil)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping ((Bool, String?) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                completion(true, nil)
            } else {
                completion(false, error!.localizedDescription as String)
            }
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func getUserName() {
        guard let user = self.session else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["fullname"]
                if let fullname = name {
                    self.session!.displayName = fullname as? String
                }
            }
        }
    }
    
    static func updateUserInfo(_ studybuddy2mutualsections: [User: [CourseSection]], completion: @escaping ([User: [CourseSection]]) -> Void = {_ in }) {
        
        SessionStore.updateUserInfo(studybuddy2mutualsections, users: Array(studybuddy2mutualsections.keys), completion: completion)
    }
    
    static func updateUserInfo(_ studybuddy2mutualsections: [User: [CourseSection]], users: [User], completion: @escaping ([User: [CourseSection]]) -> Void = {_ in }) {
        
        if users.isEmpty {
            completion(studybuddy2mutualsections)
            return
        }
        var mutatedUsers = users
        var mutatedstudybuddy2mutualsections = studybuddy2mutualsections
        let user = mutatedUsers.removeLast()
        user.fetchInfo(completion: { mutatedUser in
            let sections = studybuddy2mutualsections[user]
            mutatedstudybuddy2mutualsections[mutatedUser] = sections
            SessionStore.updateUserInfo(mutatedstudybuddy2mutualsections, users: mutatedUsers, completion: completion)
        })
    }
    
}

class User: Identifiable, Hashable {
    var uid: String
    var email: String?
    var displayName: String?
    var firstTerm: String?
    var phoneNumber: String?
    var studentOrganization: String? // [String]?
    
    init(uid: String, email: String? = nil, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
    
    var id: String {
        return uid
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func fetchDisplayNameOnly(completion: @escaping (User) -> Void = {_ in }) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(self.uid)
        docRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["fullname"]
                if let fullname = name {
                    // self.session!.displayName = fullname as? String
                    self.displayName = fullname as? String
                }
            }
            completion(self)
        }
    }
    
    public func fetchInfo(completion: @escaping (User) -> Void = {_ in }) {
        let db = Firestore.firestore()
        print("user = " + uid)
        let ref = db.collection("users").document(self.uid)
        
        ref.getDocument() { (document, error) in
            if let document = document, document.exists { // if there's a value in document, unwrap
                let data = document.data()
                let fetchedTerm = data!["startingTerm"] as? String ?? ""
                
                if let email = data!["email"] {
                    self.email = email as? String
                }
                // self.displayName = self.session.session!.displayName ?? "No full name"
                self.displayName = data!["fullname"] as? String ?? self.email ?? "No name provided"
                self.firstTerm = fetchedTerm
                
                
                self.phoneNumber = data!["phoneNumber"] as?  String ?? "No phone number"
                // print("Full name: \(fullname)")
                // print("phone number: \(phoneNumber)")
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
                
                self.studentOrganization = studOrgsFetched
                
                
                
            } else {
                print("Document does not exist in cache")
            }
            completion(self)
        }
        
        
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
