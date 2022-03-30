//
//  SignUpView.swift
//  GTStudyBuddy
//
//  Created by Ajay Moturi on 3/29/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
  @State var email = ""
  @State var password = ""
  @State var confirmPassword = ""
  @State private var showPass: Bool = false
  @State var successLogin: Bool = false

  var body: some View {
    NavigationView {
      VStack {
        Text("Sign up to be a part of GT Study Buddy!")
          .font(.title)
        
        VStack(alignment: .leading) {
          TextField("Email:", text: self.$email)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary, lineWidth: 1)
                                    .foregroundColor(.clear))
                .padding(.bottom, 30)
          
          // Use a securefield for sensitive info
          // replaces text with dots and other secure features
            if !showPass {
                HStack {
                    VStack {
                      SecureField("Password:", text: self.$password)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.secondary, lineWidth: 1)
                                                .foregroundColor(.clear))
                      
                      SecureField("Confirm Password:", text: self.$confirmPassword)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.secondary, lineWidth: 1)
                                                .foregroundColor(.clear))
                    }
                    Button(action: {
                                    showPass.toggle()
                                }, label: {
                                    Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                                })
                }
            }
            else  {
                HStack {
                    VStack {
                      TextField("Password:", text: self.$password)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.secondary, lineWidth: 1)
                                                .foregroundColor(.clear))
                      
                      TextField("Confirm Password:", text: self.$confirmPassword)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.secondary, lineWidth: 1)
                                                .foregroundColor(.clear))
                    }
                    Button(action: {
                                    showPass.toggle()
                                }, label: {
                                    Image(systemName: showPass ? "eye.slash.fill" : "eye.fill")
                                })
                }
            }
        }
        .padding()
          
        //first task: create sign in functionality
        Button(action: {
          signUp()
        }, label: {
          Text("Sign Up")
            .foregroundColor(.white)
            .frame(width: 100, height: 50)
            .background(.blue)
            .cornerRadius(15)
        })
        .padding(.top, 30)
        Spacer()
        
      }
    }
  }
  
  func signUp() {
    if password.count < 8 {
      print("Password must be at least 8 characters.")
      return
    }
    
    if password != confirmPassword {
      print("Passwords do not match.")
      return
    }
    
    
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      if let error = error as NSError? {
        switch AuthErrorCode(rawValue: error.code) {
        case .operationNotAllowed:
          // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
          print("Not allowed")
        case .emailAlreadyInUse:
          // Error: The email address is already in use by another account.
          print("Email already in use")
        case .invalidEmail:
          // Error: The email address is badly formatted.
          print("Invalid Emails")
        default:
          print("Other error")
        }
      } else {
        let db = Firestore.firestore()
        let user = authResult!.user
        db.collection("users").document(user.uid).setData(["email": user.email], merge: true)
      }
    }
  }
  
  
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
