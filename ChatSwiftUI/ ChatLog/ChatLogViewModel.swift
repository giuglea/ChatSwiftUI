//
//  ChatLogViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Firebase
import FirebaseFirestoreSwift
import UIKit

final class ChatLogViewModel: ObservableObject {
    @Published var chatText: String = ""
    @Published var chatMessages: [ChatMessage] = []
    @Published var count = 0
    @Published var errorMessage: String?
    
    var chatModel: ChatModel
    let firebaseManager: FirebaseManager
    var firestoreListener: ListenerRegistration?
    
    init(chatModel: ChatModel,
         firebaseManager: FirebaseManager) {
        self.chatModel = chatModel
        self.firebaseManager = firebaseManager
        fetchMessages()
    }
    
    func getProfileImageString() -> String {
        return chatModel.imageUrl ?? ""
    }
    
    func getName() -> String {
        return chatModel.groupName
    }
    
    func fetchMessages() {
        guard let chatModelId = chatModel.id else {
            return
        }
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        
        // TODO: Chnage this into an unique identifier: chatModelId
        firestoreListener = firebaseManager.firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(chatModelId)
            .collection(FirebaseConstants.Collection.messages)
            .order(by: FirebaseConstants.Message.timeStamp)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let welf = self else {
                    return
                }
                if let error = error {
                    welf.errorMessage = error.localizedDescription
                    return
                }
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added,
                       let chatMessage = try? change.document.data(as: ChatMessage.self) {
                        welf.chatMessages.append(chatMessage)
                    }
                }
                DispatchQueue.main.async {
                    welf.count += 1
                }
            }
    }
    
    func handleSend() {
        guard let chatModelId = chatModel.id,
              let currentUser = firebaseManager.getCurrentUser() else {
            return
        }
        
        let document = firebaseManager.firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(chatModelId)
            .collection(FirebaseConstants.Collection.messages)
            .document()
        
        let chatMessage = ChatMessage(fromId: currentUser.id ?? "",
                                      fromName: currentUser.email,
                                      text: chatText,
                                      imageUrl: "",
                                      timeStamp: Date())
        
        try? document.setData(from: chatMessage) { [weak self] error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.errorMessage = error.localizedDescription
                return
            }
            DispatchQueue.main.async {
                welf.count += 1
            }
            
            welf.persistRecentMessage()
        }
    }
    
    private func persistRecentMessage() {
        guard let id = chatModel.id,
              let currentUser = firebaseManager.getCurrentUser() else {
            return
        }
        
        let document = firebaseManager.firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .document(id)
        
        let chatMessage = ChatMessage(fromId: currentUser.id ?? "",
                                      fromName: currentUser.email,
                                      text: chatText,
                                      imageUrl: "",
                                      timeStamp: Date())
        chatModel.lastMessage = chatMessage
        
        try? document.setData(from: chatModel) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        chatText = ""
    }
    
    private func persistImageToStorage(image: UIImage?) {
        guard let uid = firebaseManager.getCurrentFirebaseUser()?.uid else {
            return
        }
        let ref = firebaseManager.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.errorMessage = "Failed to save image \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.errorMessage = "Failed to retreive download URL\(error)"
                    return
                }
                guard let url = url else { return }
                // TODO: Send message inside a que and upload the message
                // TODO: Add loading indicator
            }
        }
    }
}
