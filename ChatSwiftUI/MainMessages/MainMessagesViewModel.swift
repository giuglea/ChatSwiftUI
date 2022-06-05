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
    @Published var recentGroups: [ChatModel] = []
    
    let firebaseManager: FirebaseManager
    
    private var firebaseListener: ListenerRegistration?
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        fetchRecentMessages()
    }
    
    func onSignOut() {
        recentGroups.removeAll()
        firebaseListener?.remove()
    }
    
    func onSignIn() {
        fetchRecentMessages()
    }
    
    func fetchRecentMessages() {
        guard let currentUser = firebaseManager.getCurrentFirebaseUser() else {
            return
        }

        firebaseManager.firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .whereField(FirebaseConstants.Group.participantsNames, arrayContains: currentUser.email ?? "")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let welf = self else {
                    return
                }
                if let error = error {
                    welf.errorMessage = error.localizedDescription
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    let docID = change.document.documentID
                    
                    if let index = welf.recentGroups.firstIndex(where: { $0.id == docID }) {
                        welf.recentGroups.remove(at: index)
                    }
                    guard let chatModel = try? change.document.data(as: ChatModel.self) else {
                        return
                    }
                    welf.recentGroups.insert(chatModel, at: 0)
                }
            }
    }
}
