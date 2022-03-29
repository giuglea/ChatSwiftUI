//
//  RecentMessage.swift
//  ChatSwiftUI
//
//  Created by Tzy on 25.12.2021.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text: String
    let toID: String
    let fromID: String
    let email: String
    let profileImageUrl: String
    let timeStamp: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timeStamp, relativeTo: Date())
    }

}
