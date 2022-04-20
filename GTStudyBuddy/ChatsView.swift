//
//  ChatsView.swift
//  GTStudyBuddy
//
//  Created by Fletcher Wells on 4/3/22.
//

import SwiftUI

struct ChatsView: View {
    @Binding var sections: [CourseSection]
    @Binding var studybuddy2mutualsections: [User: [CourseSection]]
    @State var chats: [Chat] = [] // [Chat(name: "Jai Chawla"), Chat(name: "Allen Su")]
    
    var body: some View {
        List {
            ForEach (self.chats) { chat in
                NavigationLink(destination: ChatView(chat: chat), label: {
                    VStack(alignment: .leading) {
                        Text(chat.user.displayName ?? "No name provided").bold()
                        Text(chat.tagline).font(.subheadline).foregroundColor(Color(.systemGray))
                    }
                }).padding()
            }
        }.navigationTitle("Study Buddies")
        .onAppear {
            updateChats()
            /*
            SessionStore.updateUserInfo(studybuddy2mutualsections, completion: { studybuddy2mutualsections in
                // self.studybuddy2mutualsections = studybuddy2mutualsections
                updateChats()
                print("successfully fetched all user info")
            })
             */
        }
    }
    
    func updateChats() {
        chats = []
        for (user, courseSections) in studybuddy2mutualsections {
            let chat = Chat(user: user, mutualSections: courseSections)
            chats.append(chat)
        }
    }
}
