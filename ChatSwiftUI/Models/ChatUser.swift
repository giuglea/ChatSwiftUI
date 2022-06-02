//
//  ChatUser.swift
//  ChatSwiftUI
//
//  Created by Tzy on 23.11.2021.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let profileImageUrl: String
}
