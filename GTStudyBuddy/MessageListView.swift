//
//  MessageListView.swift
//  Firebase Chat
//
//  Created by Jai Chawla on 11/2/21.
//

import SwiftUI

struct MessageListView: View {
    var message: Message
    var isSender: Bool
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if isSender {
                    Spacer()
                }
                Text(message.text)
                    .padding(10)
                    .foregroundColor(isSender ? Color.white : Color.black)
                    .background(isSender ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                    .cornerRadius(10)
                if !isSender {
                    Spacer()
                }
            }
        }
        .listRowBackground(Color(UIColor.systemBackground))
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
        MessageListView(message: Message(text: "Hello", time: 123456734, sender: User(uid: "69", displayName: "John"), receiver: User(uid: "420", displayName: "Joe")), isSender: true)
    }
}
