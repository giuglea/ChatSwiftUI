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
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if let _ = error {
                    return
                }
                
                documentsSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let chatUser = ChatUser(data: data)
                    if chatUser.uid != FirebaseManager.shared.currentUser?.uid {
                        self.users.append(chatUser)
                    }
                }
            }
    }
}
