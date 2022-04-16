//
//  SessionStore.swift
//  GTStudyBuddy
//
//  Created by Jai Chawla on 4/16/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SessionStore: ObservableObject {
  var session: User?
  var hasOnboared: DocumentReference?
  var handle: AuthStateDidChangeListenerHandle?

  func listen(completion: @escaping (Bool) -> Void) {
      // monitor authentication changes using firebase
      handle = Auth.auth().addStateDidChangeListener { (auth, user) in
          if let user = Auth.auth().currentUser {
              // if we have a user, create a new user model
              print("Got user: \(String(describing: user.email))")
              self.session = User(
                  uid: user.uid,
                  email: user.email
              )
              completion(true)
          } else {
              // if we don't have a user, set our session to nil
              self.session = nil
              completion(false)
          }
      }
  }
  
  func getOnboardingData() {
    guard let user = self.session else { return }
    let db = Firestore.firestore()
    let docRef = db.collection("users").document(user.uid)
    
  }
  
}

class User {
  var uid: String
  var email: String?
  var firstName: String?
  var lastName: String?
  var crns: [String]?
  
  init(uid: String, email: String? = nil) {
      self.uid = uid
      self.email = email
  }
}
