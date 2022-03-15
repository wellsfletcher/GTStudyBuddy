//
//  Course.swift
//  CRNConverter
//
//  Created by Fletcher Wells on 3/8/22.
//

import Foundation

struct Course: Identifiable, Codable {
    var id: String
    var longTitle = ""
    var description: String?
}
