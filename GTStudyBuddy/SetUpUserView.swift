//
//  SetUpUserView.swift
//  StudyBuddy
//
//  Created by Allen Su on 3/1/22.
//

import SwiftUI

struct SetUpUserView: View {
    @State var crn: String = ""
    @State var courses: [String] = []
    @State var gradeLevel: String = ""
    @State var major: String = ""
    var body: some View {
        
        VStack {
            TextField("Enter Course CRN", text: $crn)
            
            
            Spacer()
            Text("Courses: " + getCourseString())
                .font(.title2)
            TextField("Enter Course CRN", text: $crn)
            Button {
                courses.append(crn)
                crn = ""
            } label: {
                Text("Add Course")
            }
            
        }
        .onTapGesture {
            //dismissed keyboard when user taps outside a textfield
            UIApplication.shared.endEditing()
        }
    }
    
    func getCourseString() -> String {
        var courseString = ""
        
        for course in courses {
            courseString = "\(courseString), \(course)"
        }
        return courseString
    }
}

struct SetUpUserView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpUserView()
    }
}
