//
//  MainMessagesViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 26.12.2021.
//

import Combine
import Firebase
import FirebaseFirestoreSwift

final class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    @Published private var recentGroups: [ChatModel] = []
    @Published var displayedGroups: [ChatModel] = []
    @Published var searchText = ""
    
    let firebaseManager: FirebaseManager
    
    private var firebaseListener: ListenerRegistration?
    private var subscribers: [AnyCancellable] = []
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
        fetchRecentMessages()
        searchChats()
    }
    
    func onSignOut() {
        recentGroups.removeAll()
        firebaseListener?.remove()
    }
    
    func onSignIn() {
        fetchRecentMessages()
    }
    
    func onRefresh() {
        fetchRecentMessages()
    }
    
    private func fetchRecentMessages() {
        guard let currentUser = firebaseManager.getCurrentFirebaseUser(),
              let email = currentUser.email else {
            return
        }
        
        firebaseManager.fetchRecentMessages(for: email)
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
    
    private func searchChats() {
        Publishers.CombineLatest($searchText, $recentGroups)
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] searchText, recentGroups in
                guard let welf = self else {
                    return
                }
                if searchText.isEmpty {
                    welf.displayedGroups = welf.recentGroups
                } else {
                    welf.displayedGroups = welf.recentGroups.filter { group in
                        group.groupName.contains(welf.searchText)
                    }
                }
            }
            .store(in: &subscribers)
    }
}
