//
//  CourseSection.swift
//  CRNConverter
//
//  Created by Fletcher Wells on 3/8/22.
//

import Foundation

struct CourseSection: Identifiable, Codable {
    var crn: String
    var sectionLabel: String // i.e. A, B, C, VPP, etc.
    var course: Course
    
    var id: String {
        return crn
    }
}
