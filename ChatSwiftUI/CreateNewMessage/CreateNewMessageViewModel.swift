//
//  CreateNewMessageViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Foundation

final class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Collection.users)
            .getDocuments { documentsSnapshot, error in
                if let _ = error {
                    return
                }
                
                documentsSnapshot?.documents.forEach { snapshot in
                    guard let chatUser = try? snapshot.data(as: ChatUser.self) else { return }
                    if chatUser.id != FirebaseManager.shared.currentUser?.id {
                        self.users.append(chatUser)
                    }
                }
            }
    }
}
