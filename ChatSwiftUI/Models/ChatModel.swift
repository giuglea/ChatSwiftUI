//
//  ChatModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 01.06.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatModel: Codable, Identifiable {
    @DocumentID var id: String?
    let groupName: String
    let participants: [ChatUser]?
    let participantsNames: [String]?
    let imageUrl: String?
    var lastMessage: ChatMessage?
    var timeStamp: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timeStamp, relativeTo: Date())
    }
}
