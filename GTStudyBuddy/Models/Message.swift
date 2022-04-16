//
//  Message.swift
//  Firebase Chat
//
//  Adapted from Will Said's Firebase-Chat project https://github.com/gtiosclub/Firebase-Chat
//  Created by Jai Chawla on 11/2/21.
//

import Foundation
import FirebaseDatabase

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let time: TimeInterval
    
    func send() {
        let root = Database.database().reference()
        let ref = root.child("messages").childByAutoId()
        
        let data: [String: Any] = [
            "text": self.text,
            "time": self.time
        ]
        
        ref.setValue(data)
    }
    
    static func observe(handler: @escaping (Message) -> ()) {
        let root = Database.database().reference()
        root.child("messages").observe(.childAdded) { snapshot in
            
            if let data = snapshot.value as? [String: Any],
               let text = data["text"] as? String,
               let time = data["time"] as? TimeInterval
            {
                let message = Message(text: text, time: time)
                handler(message)
            }
            
        }
    }
}
