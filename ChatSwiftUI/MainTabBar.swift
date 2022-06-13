//
//  MainTabBar.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import Combine
import SwiftUI

final class MainViewModel: ObservableObject {
    
    // MARK: ViewModels
    @Published var mainMessagesViewModel: MainMessagesViewModel
    @Published var draftMasterViewModel: DraftMasterViewModel
    @Published var settingsViewModel: SettingsViewModel
    
    // MARK: Variables
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    // MARK: Dependencies
    let fireBaseManager = FirebaseManagerImplementation()
    
    private var subscribers: [AnyCancellable] = []
    
    init() {
        mainMessagesViewModel = MainMessagesViewModel(firebaseManager: fireBaseManager)
        draftMasterViewModel = DraftMasterViewModel(firebaseManager: fireBaseManager)
        settingsViewModel = SettingsViewModel(firebaseManager: fireBaseManager)
        
        settingsViewModel.onSignOut = handleSingOut
        fetchCurrentUser()
        observeChatUser()
    }
    
    private func observeChatUser() {
        $chatUser.receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.mainMessagesViewModel.chatUser = value
                self?.draftMasterViewModel.chatUser = value
                self?.settingsViewModel.chatUser = value
            }
            .store(in: &subscribers)
    }
    
    func fetchCurrentUser() {
        guard let uid = fireBaseManager.auth.currentUser?.uid else {
            isUserCurrentlyLoggedOut = true
            return
        }
        fireBaseManager.firestore
            .collection(FirebaseConstants.Collection.users)
            .document(uid)
            .getDocument { [weak self] snapshot, error in
                guard let welf = self else {
                    return
                }
                if let error = error {
                    welf.errorMessage = error.localizedDescription
                    return
                }
                guard let chatUser = try? snapshot?.data(as: ChatUser.self) else {
                    return
                }
                welf.chatUser = chatUser
                welf.fireBaseManager.currentUser = welf.chatUser
                welf.handleSingIn()
            }
    }
    
    func handleSingIn() {
        isUserCurrentlyLoggedOut = false
        mainMessagesViewModel.onSignIn()
    }
    
    func handleSingOut() {
        mainMessagesViewModel.onSignOut()
        isUserCurrentlyLoggedOut = true
        try? fireBaseManager.auth.signOut()
    }
    
}

struct MainView: View {
    
    @StateObject var mainViewModel = MainViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                MainMessagesView(viewModel: mainViewModel.mainMessagesViewModel)
            }
            .tabItem {
                Label("Chats", systemImage: "message")
            }
            NavigationView {
                DraftMasterView(viewModel: mainViewModel.draftMasterViewModel)
            }
            .tabItem {
                Label("Draft", systemImage: "square.and.pencil")
            }
            NavigationView {
                SettingsView(viewModel: mainViewModel.settingsViewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $mainViewModel.isUserCurrentlyLoggedOut) {
            let logInViewModel = LogInViewModel(firebaseManager: mainViewModel.fireBaseManager) {
                self.mainViewModel.fetchCurrentUser()
            }
            LogInView(viewModel: logInViewModel)
        }
    }
}
