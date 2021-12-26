//
//  MainMessagesViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Firebase
import FirebaseFirestoreSwift

final class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCunrentlyLoggedOut = false
    @Published var recentMessages: [RecentMessage] = []
    
    private var firebaseListener: ListenerRegistration?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCunrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Cannnot find user"
            return
        }
        errorMessage = uid
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshhot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch user: \(error)"
                    return
                }
                
                guard let data = snapshhot?.data() else { return }
                self.chatUser = ChatUser(data: data)
                FirebaseManager.shared.currentUser = self.chatUser
            }
    }
    
    func handleSignOut() {
        recentMessages.removeAll()
        firebaseListener?.remove()
        isUserCunrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firebaseListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timeStamp)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                snapshot?.documentChanges.forEach({ change in
                    let docID = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { $0.id == docID }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    guard let recentMessage = try? change.document.data(as: RecentMessage.self) else { return }
                    self.recentMessages.insert(recentMessage, at: 0)
                })
                
            }
    }
}
