//
//  ChatsView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/3/22.
//

import SwiftUI

struct ChatsView: View {
    @Binding var sections: [CourseSection]
    @State var chats: [Chat] = [Chat(name: "Jai Chawla"), Chat(name: "Allen Su")]
    
    var body: some View {
        List {
            ForEach (self.chats) { chat in
                NavigationLink(destination: ChatView(chat: chat), label: {
                    Text(chat.name)
                }).padding()
            }
        }.navigationTitle("Study Buddies")
    }
}
