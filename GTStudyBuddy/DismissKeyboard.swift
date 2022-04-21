//
//  DismissKeyboard.swift
//  GTStudyBuddy
//
//  Created by Gregory Boyd on 4/20/22.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
