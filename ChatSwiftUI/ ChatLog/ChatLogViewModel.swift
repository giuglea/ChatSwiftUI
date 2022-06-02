//
//  ChatLogViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Firebase
import FirebaseFirestoreSwift

final class ChatLogViewModel: ObservableObject {
    @Published var chatText: String = ""
    @Published var chatMessages: [ChatMessage] = []
    @Published var count = 0
    
    var chatModel: ChatModel
    var firestoreListener: ListenerRegistration?
    
    init(chatModel: ChatModel) {
        self.chatModel = chatModel
        fetchMessages()
    }
    
    func getProfileImageString() -> String {
        return chatModel.imageUrl ?? ""
    }
    
    func getName() -> String {
        return chatModel.groupName
    }
    
    func fetchMessages() {
        guard let id = chatModel.id else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(id)
            .collection(FirebaseConstants.Collection.messages)
            .order(by: FirebaseConstants.Message.timeStamp)
            .addSnapshotListener { snapshot, error in
                if let _ = error {
                    return
                }
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added,
                       let chatMessage = try? change.document.data(as: ChatMessage.self) {
                        self.chatMessages.append(chatMessage)
                    }
                }
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
        guard let id = chatModel.id else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(id)
            .collection(FirebaseConstants.Collection.messages)
            .document()
        
        let chatMessage = ChatMessage(fromId: currentUser.id ?? "",
                                      fromName: currentUser.email,
                                      text: chatText,
                                      imageUrl: "",
                                      timeStamp: Date())
        
        try? document.setData(from: chatMessage) { [weak self] error in
            guard let welf = self else { return }
            
            if let error = error {
                print(error)
            }
            DispatchQueue.main.async {
                welf.count += 1
            }
            
            welf.persistRecentMessage()
        }
    }
    
    private func persistRecentMessage() {
        guard let id = chatModel.id else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .document(id)
        
        let chatMessage = ChatMessage(fromId: currentUser.id ?? "",
                                      fromName: currentUser.email,
                                      text: chatText,
                                      imageUrl: "",
                                      timeStamp: Date())
        chatModel.lastMessage = chatMessage
        
        try? document.setData(from: chatModel) { error in
            if let error = error {
                print(error)
            }
        }
        self.chatText = ""
    }
}
