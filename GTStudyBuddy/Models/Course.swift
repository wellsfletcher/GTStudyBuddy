//
//  Course.swift
//  CRNConverter
//
//  Created by Fletcher Wells on 3/8/22.
//

import Foundation

struct Course: Identifiable, Codable {
    var id: String // i.e. CS 1332
    var longTitle = ""
    var description: String?
    
    static let invalid: Course = Course(id: "XX 9999", longTitle: "Invalid Course", description: "This is an invalid course. Something has gone wrong.")
}
