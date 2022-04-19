//
//  Chat.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/3/22.
//

import Foundation

struct Chat: Identifiable {
    var id = UUID()
    var user: User
    
    var mutualSections: [CourseSection] = []
    
    var name: String {
        return user.displayName ?? "Anonymous"
    }
    
    var tagline: String {
        return mutualSections.map{$0.course.id}.joined(separator: ", ")
    }
}
