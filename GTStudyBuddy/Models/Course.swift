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
}
