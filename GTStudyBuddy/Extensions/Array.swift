//
//  Array.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/17/22.
//

import Foundation

extension Array where Element: Hashable {
    func subtract(from other: [Element]) -> [Element] {
        var thisSet = Set(self)
        let otherSet = Set(other)
        thisSet.subtract(otherSet)
        return Array(thisSet)
    }
    
    func symmetricDifference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
