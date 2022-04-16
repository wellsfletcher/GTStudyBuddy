//
//  ChatView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/3/22.
//

import SwiftUI

struct ChatView: View {
    @State var chat: Chat
    @State var text = ""
    @State var messages: [Message] = []
    
    var body: some View {
        VStack {
            HStack {
                TextField("Message", text: self.$text)
                
                Button(action: {
                    self.send()
                }, label: {
                    Text("Send")
                })
            }
            .padding()
            
            List {
                ForEach(messages) { message in
                    MessageListView(message: message)
                }
            }
        }.navigationTitle(chat.name)
        .onAppear {
            fetchMessages()
        }
    }
    
    func send() {
        let time = Date().timeIntervalSince1970
        Message(text: self.text, time: time).send()
        self.text = ""
    }
    
    func fetchMessages() {
        Message.observe { message in
            self.messages.insert(message, at: 0)
            self.messages.sort(by: { (m1, m2) -> Bool in
                return m1.time > m2.time
            })
        }
    }
}
