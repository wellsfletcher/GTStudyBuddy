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
  @EnvironmentObject var session: SessionStore
  
  @State var fullName = ""
  @State var email = ""
  @State var password = ""
  @State var confirmPassword = ""
  @State private var showPass: Bool = false
  @State var successLogin: Bool = false
  @State var showingAlert = false
  @State var errorMessage = ""
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        TextField("Your Full Name:", text: self.$fullName)
              .disableAutocorrection(true)
          .padding()
          .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray3), lineWidth: 1)
                    .foregroundColor(.clear))
          .padding(.bottom, 30)
        
        TextField("Email:", text: self.$email)
              .disableAutocorrection(true)
              .textInputAutocapitalization(.never)
          .padding()
          .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray3), lineWidth: 1)
                    .foregroundColor(.clear))
          .padding(.bottom, 30)
        
        // Use a securefield for sensitive info
        // replaces text with dots and other secure features
            VStack {
              SecureInputView("Password:", text: self.$password)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12)
                          .stroke(Color(.systemGray3), lineWidth: 1)
                          .foregroundColor(.clear))
              
              SecureInputView("Confirm Password:", text: self.$confirmPassword)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12)
                          .stroke(Color(.systemGray3), lineWidth: 1)
                          .foregroundColor(.clear))
            }
         
         
      }
      .padding()
      
      //first task: create sign in functionality
        Button(action: {
          session.signUp(name: self.fullName, email: self.email, password: self.password, confirmPassword: self.confirmPassword) { (signUpSuccessful, error) in
            if let error = error {
              self.errorMessage = error
              self.showingAlert = true
            }
            if signUpSuccessful {
              self.successLogin = true
            }
          }
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
    .navigationTitle("Join GT Study Buddy")
    .padding()
    .alert(isPresented: self.$showingAlert) {
      Alert(title: Text("Error"), message: Text(self.errorMessage), dismissButton: .default(Text("Try Again")))
    }
  }
}

struct SignUpView_Previews: PreviewProvider {
  static var previews: some View {
    SignUpView()
      .environmentObject(SessionStore())
  }
}
