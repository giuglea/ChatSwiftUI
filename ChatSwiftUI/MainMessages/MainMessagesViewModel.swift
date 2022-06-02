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
    
    private var firebaseListener: ListenerRegistration?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCunrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func getAllChatUsers() -> [ChatModel] {
        return recentGroups
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            errorMessage = "Cannnot find user"
            return
        }
        errorMessage = uid
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Collection.users)
            .document(uid)
            .getDocument { [weak self] snapshot, error in
                guard let welf = self else { return }
                if let error = error {
                    welf.errorMessage = "Failed to fetch user: \(error)"
                    return
                }
                
                guard let chatUser = try? snapshot?.data(as: ChatUser.self) else { return }
                welf.chatUser = chatUser
                FirebaseManager.shared.currentUser = welf.chatUser
            }
    }
    
    func handleSignOut() {
        recentGroups.removeAll()
        firebaseListener?.remove()
        isUserCunrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    func fetchRecentMessages() {
        guard let user = FirebaseManager.shared.auth.currentUser else { return }
        

        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .whereField(FirebaseConstants.Group.participantsNames, arrayContains: user.email ?? "")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    let docID = change.document.documentID
                    
                    if let index = self.recentGroups.firstIndex(where: { $0.id == docID }) {
                        self.recentGroups.remove(at: index)
                    }
                    guard let chatModel = try? change.document.data(as: ChatModel.self) else { return }
                    self.recentGroups.insert(chatModel, at: 0)
                }
            }
    }
}

extension Encodable {

    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
