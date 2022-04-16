import SwiftUI
import Firebase
import Combine

class SessionStore: ObservableObject {
    @Published var session: User?
    var handle: AuthStateDidChangeListenerHandle?

    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = User(
                    uid: user.uid,
                    email: user.email,
                    displayName: user.displayName
                )
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
        }
    }

    // additional methods (sign up, sign in) will go here
  
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
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { error in
          // ...
        }
        db.collection("users").document(user.uid).setData(["email": user.email!], merge: true)
        completion(true, nil)
      }
    }
  }

}

class User {
    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, email: String? = nil, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}
