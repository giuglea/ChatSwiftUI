//
//  ChatUser.swift
//  ChatSwiftUI
//
//  Created by Tzy on 23.11.2021.
//

import Foundation

struct ChatUser: Identifiable {
    var id: String {
        return uid
    }
    
    let uid: String
    let email: String
    let profileImageUrl: String
    
    init(data: [String: Any]) {
        uid = data[FirebaseConstants.uid] as? String ?? ""
        email = data[FirebaseConstants.email] as? String ?? ""
        profileImageUrl = data[FirebaseConstants.profileImageURL] as? String ?? ""
    }
}
