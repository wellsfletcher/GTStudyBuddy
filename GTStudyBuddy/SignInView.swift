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
  @State var email = ""
  @State var password = ""
  @State var successLogin: Bool = false
  @State var showPass: Bool = false
  @State var signUp: Bool = false
  
  var body: some View {
    NavigationView {
      VStack {
        Text("Sign in to GT Study Buddy:")
          .font(.title)
        
        VStack(alignment: .leading) {
            TextField("Email:", text: self.$email)
                  .padding()
                  .overlay(RoundedRectangle(cornerRadius: 12)
                                      .stroke(Color.secondary, lineWidth: 1)
                                      .foregroundColor(.clear))

          // Use a securefield for sensitive info
          // replaces text with dots and other secure features
            HStack {
                if !showPass {
                    SecureField("Password:", text: self.$password)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.secondary, lineWidth: 1)
                                            .foregroundColor(.clear))
                } else {
                    TextField("Password:", text: self.$password)
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
        })
            .padding()
        NavigationLink(destination: CRNSetupView(), isActive: $successLogin) {
          EmptyView()
        }
          
          NavigationLink(destination: SignUpView(), isActive: $signUp) {
              Button(action: {
                  signUp = true
              }, label: {
                  Text("Sign Up")
                      .frame(width: 100, height: 50)
                      .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 2)
                      )
              })
          }
        Spacer()
        
      }
    }
    
    .padding()
  }
  
  func logIn() {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
      if error == nil {
        successLogin = true
        print("successfully logged in")
      } else {
        print(error?.localizedDescription as Any)
        
      }
    }
  }
}
    
struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView()
  }
}
