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
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    
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
    
    func didTapSend() {
        if let selectedImage = selectedImage {
            isLoading = true
            persistImageToStorage(selectedImage: selectedImage) { [weak self] urlString in
                self?.handleSend(urlString: urlString)
                self?.isLoading = false
            }
        } else {
            handleSend()
        }
    }
    
    private func handleSend(urlString: String = "") {
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
                                      imageUrl: urlString,
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
            
            welf.persistRecentMessage(urlString: urlString)
        }
    }
    
    private func persistRecentMessage(urlString: String) {
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
                                      imageUrl: urlString,
                                      timeStamp: Date())
        chatModel.lastMessage = chatMessage
        
        try? document.setData(from: chatModel) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        chatText = ""
    }
    
    private func persistImageToStorage(selectedImage: UIImage, completion: @escaping (String) -> ()) {
        firebaseManager.persistImageToStorage(image: selectedImage) { [weak self] urlString, error in
            if let error = error {
                self?.errorMessage = "Failed to save image \(error)"
                return
            }
            guard let urlString = urlString else {
                return
            }
            completion(urlString)
            
            // TODO: Send message inside a que and upload the message
        }
    }
}
