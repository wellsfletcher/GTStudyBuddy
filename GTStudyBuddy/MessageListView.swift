//
//  MessageListView.swift
//  Firebase Chat
//
//  Created by Jai Chawla on 11/2/21.
//

import SwiftUI

struct MessageListView: View {
    var message: Message
    var body: some View {
        VStack(alignment: .leading) {
            Text(message.text)
                .padding(10)
                .foregroundColor(true ? Color.white : Color.black)
                .background(true ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                .cornerRadius(10)
            Text(convertTimeIntervalToDate()).font(.subheadline).fontWeight(.light)
        }
    }
    
    func convertTimeIntervalToDate() -> String {
        let date = Date(timeIntervalSince1970: message.time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView(message: Message(text: "Hello", time: 123456734, sender: User(uid: "69"), receiver: User(uid: "420")))
    }
}
