//
//  CreateNewMessageViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Foundation

struct SelectableChatUser: Identifiable {
    var id: String? {
        return chatUser.id
    }
    
    var isSelected: Bool = false
    var chatUser: ChatUser
}

final class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [SelectableChatUser] = []
    @Published var errorMessage: String?
    @Published var canCreateChat = false
    
    let firebaseManager: FirebaseManager
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        fetchAllUsers()
    }
    
    func didSelectUser(with id: String?) {
        guard let id = id,
              let index = users.firstIndex(where: { $0.id == id }) else {
            return
        }
        users[index].isSelected.toggle()
        canCreateChat = users.contains(where: { user in
            user.isSelected
        })
    }
    
    private func fetchAllUsers() {
        let currentUserId = firebaseManager.getCurrentUser()?.id
        firebaseManager.firestore
            .collection(FirebaseConstants.Collection.users)
            .getDocuments { [weak self] documentsSnapshot, error in
                guard let welf = self else {
                    return
                }
                if let error = error {
                    welf.errorMessage = error.localizedDescription
                    return
                }
                
                documentsSnapshot?.documents.forEach { snapshot in
                    guard let chatUser = try? snapshot.data(as: ChatUser.self) else {
                        return
                    }
                    
                    if chatUser.id != currentUserId {
                        let selectableChatUser = SelectableChatUser(chatUser: chatUser)
                        welf.users.append(selectableChatUser)
                    }
                }
            }
    }
}
