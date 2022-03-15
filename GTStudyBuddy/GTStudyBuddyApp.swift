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
    
    var body: some Scene {
        WindowGroup {
            SignInView()
        }
    }
}
