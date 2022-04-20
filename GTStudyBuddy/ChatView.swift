//
//  ChatView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/3/22.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var session: SessionStore
    
    @State var chat: Chat
    @State var text = ""
    @State var messages: [Message] = []
    
    var sender: User {
        return session.session!
    }
    
    var receiver: User {
        return chat.user
    }
    
    var body: some View {
        VStack {
            
            
            List {
                ForEach(messages.reversed()) { message in
                    // MessageListView(message: message, isSender: session.session?.uid == sender.uid)
                    MessageListView(message: message, isSender: sender.uid == message.sender.uid)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .padding([.leading, .trailing], 16)

            HStack {
                TextField("Start typing...", text: self.$text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                Button(action: {
                    self.send()
                }, label: {
                    // Text("Send")
                    Image(systemName: "arrowtriangle.right.fill").padding(.leading)
                }).disabled(self.text.isEmpty)
            }
            .frame(minHeight: CGFloat(50)).padding()
                .padding([.leading, .trailing], 16)
        }
        .navigationTitle(chat.name).navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchMessages()
            }
    }
    
    func send() {
        let time = Date().timeIntervalSince1970
        Message(text: self.text, time: time, sender: sender, receiver: receiver).send()
        self.text = ""
    }
    
    func fetchMessages() {
        Message.observe(sender: sender, receiver: receiver) { message in
            self.messages.insert(message, at: 0)
            self.messages.sort(by: { (m1, m2) -> Bool in
                return m1.time > m2.time
            })
        }
    }
}
