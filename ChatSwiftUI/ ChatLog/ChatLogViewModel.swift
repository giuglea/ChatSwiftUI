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
    
    var chatUser: ChatUser
    var firestoreListener: ListenerRegistration?
    
    init(chatUser: ChatUser) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    func getProfileImageString() -> String {
        return chatUser.profileImageUrl
    }
    
    func getEmailString() -> String {
        return chatUser.email
    }
    
    func fetchMessages() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let toID = chatUser.uid
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromID)
            .collection(toID)
            .order(by: FirebaseConstants.timeStamp)
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
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let toID = chatUser.uid
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromID)
            .collection(toID)
            .document()
        
        let messageData = [FirebaseConstants.fromID: fromID,
                           FirebaseConstants.toID: toID,
                           FirebaseConstants.text: chatText,
                           FirebaseConstants.timeStamp: Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
            }
            DispatchQueue.main.async {
                self.count += 1
            }
            
            self.persistRecentMessage()
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toID)
            .collection(fromID)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                return
            }
            
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let toID = chatUser.uid
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toID)
        
        let data = [
            FirebaseConstants.timeStamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromID: uid,
            FirebaseConstants.toID: toID,
            FirebaseConstants.profileImageURL: self.chatUser.profileImageUrl,
            FirebaseConstants.email: self.chatUser.email
        ] as [String : Any]
        
        document.setData(data) { error in
            if let _ = error {
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        
        let receiverdata = [
            FirebaseConstants.timeStamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromID: uid,
            FirebaseConstants.toID: toID,
            FirebaseConstants.profileImageURL: currentUser.photoURL?.absoluteString ?? String(),
            FirebaseConstants.email: currentUser.email ?? String()
        ] as [String : Any]
        
        let receiverDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toID)
            .collection(FirebaseConstants.messages)
            .document(uid)
        
        receiverDocument.setData(receiverdata) { error in
            if let _ = error {
                return
            }
        }
        
        self.chatText = ""
    }
}
