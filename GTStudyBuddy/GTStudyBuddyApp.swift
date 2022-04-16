//
//  GTStudyBuddyApp.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 3/8/22.
//

import SwiftUI
import Firebase

@main
struct GTStudyBuddyApp: App {
  init() {
    FirebaseApp.configure()
  }
  
  @StateObject var session = SessionStore()
  @State var hasLoaded = false
  
  var body: some Scene {
    WindowGroup {
      if !hasLoaded {
        LogoView(hasLoaded: self.$hasLoaded)
          .environmentObject(session)
      } else {
        if session.session != nil {
          CRNSetupView()
            .environmentObject(session)
        } else {
          SignInView()
            .environmentObject(session)
        }
      }
    }
  }
}
