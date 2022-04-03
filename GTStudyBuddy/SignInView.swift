//
//  SignInView.swift
//  StudyBuddy
//
//  Created by Allen Su on 3/1/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignInView: View {
  @State var showPass: Bool = false
  @State var signUp: Bool = false

  @State var email = "gwells9@gatech.edu"
  @State var password = "password"
  @State var confirmPassword = ""
  @State var successLogin: Bool = false
  @State var uid: String?
  @State var showInformationForm: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
    
        VStack(alignment: .leading) {
            TextField("Email:", text: self.$email)
                  .padding()
                  .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                                      .foregroundColor(.clear))

          // Use a securefield for sensitive info
          // replaces text with dots and other secure features
            HStack {
                if !showPass {
                    SecureField("Password:", text: self.$password)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray3), lineWidth: 1)
                                            .foregroundColor(.clear))
                } else {
                    TextField("Password:", text: self.$password)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray3), lineWidth: 1)
                                            .foregroundColor(.clear))
                }
                Button(action: {
                                showPass.toggle()
                            }, label: {
                                Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                            })
            }
                .padding(.top)
            
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
        }).padding()
        // .padding()
        NavigationLink(destination: CRNSetupView(uid: self.uid), isActive: $successLogin) {
          EmptyView()
        }
        NavigationLink(destination: InformationForm(uid: self.uid), isActive: $showInformationForm){
          EmptyView()
        }
        
        //first task: create sign in functionality
          /*
        Button(action: {
          //- signUp()
        }, label: {
          Text("Sign Up")
            .foregroundColor(.white)
            .frame(width: 100, height: 50)
            .background(.blue)
            .cornerRadius(15)
        })
           */
          Button(action: {
            fillform()
          }, label: {
            Text("Fill Information Form")
              .foregroundColor(.white)
              .frame(width: 200, height: 50)
              .background(.blue)
              .cornerRadius(15)
          })
        
          NavigationLink(destination: SignUpView(), isActive: $signUp) {
              Button(action: {
                  signUp = true
              }, label: {
                  Text("Sign Up")
                      .frame(width: 100, height: 50)
                      .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                      )
              })
          } // .padding()
        Spacer()
        
      }.navigationTitle("Enter GT Study Buddy").padding()
    }
    
  }
  
  func logIn() {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
      if error == nil {
        self.uid = authResult!.user.uid
        successLogin = true
        print("successfully logged in")
      } else {
        print(error?.localizedDescription as Any)
        
      }
    }
  }

    func fillform() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
          if error == nil {
            self.uid = authResult!.user.uid
            showInformationForm = true
          } else {
            print(error?.localizedDescription as Any)
          }
        }
    }
  
  /*
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
        self.uid = user.uid
        db.collection("users").document(user.uid).setData(["email": user.email], merge: true)
      }
    }
  }
  */
  
}
    
struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView()
  }
}
