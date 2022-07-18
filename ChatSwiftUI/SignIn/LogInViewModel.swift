//
//  LogInViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import UIKit

final class LogInViewModel: ObservableObject {
    let firebaseManager: FirebaseManager
    var didCompleteLogIn : () -> ()
    
    @Published var isLoginMode = false
    @Published var email = ""
    @Published var password = ""
    @Published var shouldShowImagePicker = false
    @Published var image: UIImage?
    @Published var loginStatusMeesage = ""
    @Published var isLoading = false
    
    init(firebaseManager: FirebaseManager, didCompleteLogIn: @escaping () -> ()) {
        self.firebaseManager = firebaseManager
        self.didCompleteLogIn = didCompleteLogIn
    }
    
    func loginUser() {
        firebaseManager.loginUser(withEmail: email, password: password) { [weak self] error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.loginStatusMeesage = "Failed to log in user: \(error)"
                return
            }
            welf.didCompleteLogIn()
        }
    }
    
    func createNewAccount() {
        if self.image == nil {
            self.loginStatusMeesage = "You must select an avatar image"
            return
        }
        isLoading = true
        firebaseManager.createNewAccount(withEmail: email, password: password) { [weak self] error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.loginStatusMeesage = "Failed to create user: \(error)"
                welf.isLoading = false
                return
            }
            welf.loginStatusMeesage = "Success in creating User"
            welf.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        firebaseManager.persistImageToStorage(image: image) { [weak self] urlString, error in
            if let error = error {
                self?.loginStatusMeesage = "Failed to save image \(error)"
                self?.isLoading = false
                return
            }
            
            guard let url = urlString else {
                return
            }
            
            self?.storeUserInformation(imageProfileUrl: url)
        }
    }
    
    private func storeUserInformation(imageProfileUrl: String) {
        guard let uid = firebaseManager.getCurrentFirebaseUser()?.uid else { return }
        let chatUser = ChatUser(id: uid,
                                email: email,
                                profileImageUrl: imageProfileUrl)
        try? firebaseManager.firestore.collection(FirebaseConstants.Collection.users)
            .document(uid)
            .setData(from: chatUser) { [weak self] error in
                guard let welf = self else {
                    return
                }
                welf.isLoading = false
                if let error = error {
                    print(error)
                    welf.loginStatusMeesage = error.localizedDescription
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    welf.didCompleteLogIn()
                }
            }
    }
    
    
}
