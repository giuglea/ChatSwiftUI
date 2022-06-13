//
//  FirebaseConstants.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Foundation

enum FirebaseConstants {
    enum Message {
        static let timeStamp = "timeStamp"
    }
    
    enum Group {
        static let groupId = "groupId"
        static let groupName = "groupName"
        static let participantsNames = "participantsNames"
    }
    
    enum Collection {
        static let messages = "messages"
        static let users = "users"
        static let recentMessages = "recentMessages"
    }
    
    enum Compression {
        static let imageCompression = 0.4
    }
}
