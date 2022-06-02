//
//  FirebaseConstants.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Foundation

enum FirebaseConstants {
    enum Message {
        static let id = "id"
        static let text = "text"
        static let timeStamp = "timeStamp"
        static let profileImageURL = "profileImageUrl"
        static let email = "email"
        static let fromId = "fromId"
    }
    
    enum Group {
        static let groupId = "groupId"
        static let groupName = "groupName"
        static let participantsNames = "participantsNames"
        static let lastMessage = "lastMessage"
        static let lastMessageName = "lastMessageName"
        static let participants = "participants"
    }
    
    enum Collection {
        static let messages = "messages"
        static let users = "users"
        static let recentMessages = "recent_messages"
    }
}
