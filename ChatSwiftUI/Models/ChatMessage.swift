//
//  ChatMessage.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromID: String
    let toID: String
    let text: String?
    let imageUrl: String?
}
