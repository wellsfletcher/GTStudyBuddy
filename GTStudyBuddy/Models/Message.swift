//
//  Message.swift
//  Firebase Chat
//
//  Adapted from Will Said's Firebase-Chat project https://github.com/gtiosclub/Firebase-Chat
//  Created by Jai Chawla on 11/2/21.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let time: TimeInterval
    
    let sender: User
    let receiver: User
    var chatId: String {
        return Message.getChatId(sender: sender, receiver: receiver)
    }
    
    static func getChatId(sender: User, receiver: User) -> String {
        let A = sender.uid
        let B = receiver.uid
        var AB: [String] = [A, B]
        AB.sort()
        return AB[0] + "," + AB[1]
    }
    
    static func getReceiverFromChatId(chatId: String, sender: User) -> String {
        let senderUID = sender.uid
        var AB: Set<String> = Set(chatId.components(separatedBy: ","))
        AB.remove(senderUID)
        return AB.removeFirst()
    }
    
    func send() {
        let root = Database.database().reference()
        let ref = root.child(chatId).child("messages").childByAutoId()
        
        let data: [String: Any] = [
            "text": self.text,
            "time": self.time,
            "sender": self.sender.uid
        ]
        
        ref.setValue(data)
    }
    
    static func observe(sender: User, receiver: User, handler: @escaping (Message) -> ()) {
        let chatId = Message.getChatId(sender: sender, receiver: receiver)
        let root = Database.database().reference()
        root.child(chatId).child("messages").observe(.childAdded) { snapshot in
            
            if let data = snapshot.value as? [String: Any],
               let text = data["text"] as? String,
               let time = data["time"] as? TimeInterval,
               let senderUID = data["sender"] as? String
            {
                // let messageSender = User(uid: senderUID, displayName: sender.displayName)
                let otherUser = receiver
                let currentUser = Auth.auth().currentUser! // this should also just be the sender
                // let displayName = user.displayName!
                let DEFAULT_NAME = "No name provided"
                var senderDisplayName = DEFAULT_NAME
                var receiverDisplayName = DEFAULT_NAME
                if currentUser.uid != senderUID {
                    senderDisplayName = otherUser.displayName ?? DEFAULT_NAME
                    receiverDisplayName = currentUser.displayName ?? DEFAULT_NAME
                } else {
                    senderDisplayName = currentUser.displayName ?? DEFAULT_NAME
                    receiverDisplayName = otherUser.displayName ?? DEFAULT_NAME
                }
                let messageSender = User(uid: senderUID, displayName: senderDisplayName) // this incorrect
                let messageReceiver = User(uid: getReceiverFromChatId(chatId: chatId, sender: messageSender), displayName: receiverDisplayName)
                let message = Message(text: text, time: time, sender: messageSender, receiver: messageReceiver)
                handler(message)
            }
            
        }
    }
}
