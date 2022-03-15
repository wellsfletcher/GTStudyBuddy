//
//  Term.swift
//  CRNConverter
//
//  Created by Fletcher Wells on 3/8/22.
//

import Foundation

struct Term: Identifiable, Codable {
    var id: String // i.e. 202202, 202108, etc.
    var name: String { // i.e. Spring 2022, Fall 2021, etc.
        get {
            let year: String = String(id.prefix(4))
            let month: String = String(id.suffix(2))
            var semester = ""
            
            if (month == "02") {
                semester = "Spring"
            } else if (month == "05") {
                semester = "Summer"
            } else if (month == "08") {
                semester = "Fall"
            }
            
            var termName = year
            if semester != "" {
                termName = semester + " " + year
            }
            
            return termName
        }
    }
}
