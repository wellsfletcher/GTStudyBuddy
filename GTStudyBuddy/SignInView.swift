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
    @EnvironmentObject var session: SessionStore
    
    @State var showPass: Bool = false
    @State var signUp: Bool = false
    
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var successLogin: Bool = false
    @State var showInformationForm: Bool = false
    @State var showingAlert = false
    @State var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                
                VStack(alignment: .leading) {
                    TextField("Email:", text: self.$email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                                    .foregroundColor(.clear))
                    
                    // Use a securefield for sensitive info
                    // replaces text with dots and other secure features
                    SecureInputView("Password:", text: self.$password)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                                    .foregroundColor(.clear))
                        .padding(.top)
                    
                }
                .padding()
                
                Button(action: {
                    session.signIn(email: self.email, password: self.password) { (signInSuccessful, error) in
                        if let error = error {
                            self.errorMessage = error
                            self.showingAlert = true
                        }
                        if signInSuccessful {
                            self.successLogin = true
                        }
                    }
                }, label: {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 50)
                        .background(.blue)
                        .cornerRadius(15)
                }).padding()
                // .padding()
                
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
                
            }
            .navigationTitle("Enter GT Study Buddy")
            .alert(isPresented: self.$showingAlert) {
                Alert(title: Text("Error"), message: Text(self.errorMessage), dismissButton: .default(Text("Try Again")))
            }
            .padding()
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(SessionStore())
    }
}
