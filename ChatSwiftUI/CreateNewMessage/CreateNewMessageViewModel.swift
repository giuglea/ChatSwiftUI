//
//  CreateNewMessageViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Combine
import UIKit

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
    @Published var selectedImage: UIImage?
    @Published var groupName: String = ""
    @Published var shouldShowImagePicker = false
    @Published var shouldShowLoading = false
    
    private var chatModel: ChatModel?
    
    let firebaseManager: FirebaseManager
    private var subscribers: [AnyCancellable] = []
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        fetchAllUsers()
        updateCanCreateChat()
    }
    
    func didSelectUser(with id: String?) {
        guard let id = id,
              let index = users.firstIndex(where: { $0.id == id }) else {
            return
        }
        users[index].isSelected.toggle()
    }
    
    private func updateCanCreateChat() {
        Publishers.CombineLatest3($users, $selectedImage, $groupName)
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] users, selectedImage, groupName in
                self?.canCreateChat = !groupName.isEmpty
                && selectedImage != nil
                && users.contains(where: { user in
                    user.isSelected
                })
            }
            .store(in: &subscribers)
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
    
    private func persistImageToStorage(image: UIImage?) {
        guard let image = image else {
            return
        }

        firebaseManager.persistImageToStorage(image: image) { [weak self] urlString, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
            
            if let urlString = urlString {
                self?.shouldShowLoading = false
            }
        }
    }
}
