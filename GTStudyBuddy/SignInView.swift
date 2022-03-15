//
//  SignInView.swift
//  StudyBuddy
//
//  Created by Allen Su on 3/1/22.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var successLogin: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Sign up to be a part of GT Study Buddy!")
                    .font(.title)
                
                VStack(alignment: .leading) {
                    TextField("Email", text: self.$email)
                    
                    // Use a securefield for sensitive info
                    // replaces text with dots and other secure features
                    SecureField("Password", text: self.$password)
                    
                    SecureField("Confirm Password", text: self.$confirmPassword)
                }
                .padding()
                
                Button(action: {
                    logIn()
                }, label: {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(.blue)
                        .cornerRadius(15)
                })
                NavigationLink(destination: CRNSetupView(), isActive: $successLogin) {
                    EmptyView()
                }
                
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
                Spacer()
                
            }
        }
        
        .padding()
    }
    
    func logIn() {
        print("log in touched")
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                successLogin = true
                print("ran here")
            } else {
                print(error?.localizedDescription)
                
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
            }
        }
    }
    
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
