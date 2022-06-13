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
    
    init(firebaseManager: FirebaseManager, didCompleteLogIn: @escaping () -> ()) {
        self.firebaseManager = firebaseManager
        self.didCompleteLogIn = didCompleteLogIn
    }
    
    func loginUser() {
        firebaseManager.auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.loginStatusMeesage = "Failed to log in user: \(error)"
                return
            }
            welf.loginStatusMeesage = "Success log in: \(result?.user.uid ?? "")"
            welf.didCompleteLogIn()
        }
    }
    
    func createNewAccount() {
        if self.image == nil {
            self.loginStatusMeesage = "You must select an avatar image"
            return
        }
        
        firebaseManager.auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.loginStatusMeesage = "Failed to create user: \(error)"
                return
            }
            welf.loginStatusMeesage = "Success create: \(result?.user.uid ?? "")"
            welf.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        firebaseManager.persistImageToStorage(image: image) { [weak self] urlString, error in
            if let error = error {
                self?.loginStatusMeesage = "Failed to save image \(error)"
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
                if let error = error {
                    print(error)
                    welf.loginStatusMeesage = error.localizedDescription
                    welf.didCompleteLogIn()
                }
            }
        
        // TODO: Add loading indicator
    }
    
    
}
