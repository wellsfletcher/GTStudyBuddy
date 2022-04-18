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
  @State var uid: String?
  @State var showingAlert: Bool = false
  @State var errorMessage: String = ""

  var body: some View {
      VStack {
        VStack(alignment: .leading) {
          TextField("Email:", text: self.$email)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                                    .foregroundColor(.clear))
                .padding(.bottom, 30)
          
          // Use a securefield for sensitive info
          // replaces text with dots and other secure features
            HStack {
                if !showPass {
                    VStack {
                      SecureField("Password:", text: self.$password)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray3), lineWidth: 1)
                                                .foregroundColor(.clear))
                      
                      SecureField("Confirm Password:", text: self.$confirmPassword)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray3), lineWidth: 1)
                                                .foregroundColor(.clear))
                    }
                } else {
                    VStack {
                      TextField("Password:", text: self.$password)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray3), lineWidth: 1)
                                                .foregroundColor(.clear))
                      
                      TextField("Confirm Password:", text: self.$confirmPassword)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray3), lineWidth: 1)
                                                .foregroundColor(.clear))
                    }
                }
                Button(action: {
                                showPass.toggle()
                            }, label: {
                                Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                            })
        }
        }
        .padding()
          
        //first task: create sign in functionality
          NavigationLink(destination: CRNSetupView(uid: self.uid), isActive: $successLogin) {
              Button(action: {
              signUp()
            }, label: {
              Text("Sign Up")
                .foregroundColor(.white)
                .frame(width: 100, height: 50)
                .background(.blue)
                .cornerRadius(15)
            })
            .padding(.top, 30).alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
          }
        Spacer()
      }.navigationTitle("Join GT Study Buddy").padding()
    }
  
  func signUp() {
    if password.count < 8 {
      print("Password must be at least 8 characters.")
      showingAlert = true
      errorMessage = "Password must be at least 8 characters."
      return
    }
    
    if password != confirmPassword {
      print("Passwords do not match.")
      showingAlert = true
      errorMessage = "Passwords do not match."
      return
    }
    
    
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      if let error = error as NSError? {
        switch AuthErrorCode(rawValue: error.code) {
        case .operationNotAllowed:
          // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
          print("Not allowed")
          errorMessage = "Not allowed"
          showingAlert = true
        case .emailAlreadyInUse:
          // Error: The email address is already in use by another account.
          print("Email already in use")
          errorMessage = "Email already in use"
          showingAlert = true
        case .invalidEmail:
          // Error: The email address is badly formatted.
          print("Invalid Emails")
          errorMessage = "Invalid Emails"
          showingAlert = true
        default:
          print("Other error")
          errorMessage = "Other error"
          showingAlert = true
        }
      } else {
        let db = Firestore.firestore()
        let user = authResult!.user
        self.uid = user.uid
        db.collection("users").document(user.uid).setData(["email": user.email], merge: true)
        successLogin = true
      }
    }
  }
  
  
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
