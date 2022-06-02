//
//  ChatMessage.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId: String
    let fromName: String
    let text: String?
    let imageUrl: String?
    var timeStamp: Date
}
