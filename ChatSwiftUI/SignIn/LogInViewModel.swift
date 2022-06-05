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
        guard let uid = firebaseManager.getCurrentFirebaseUser()?.uid else {
            return
        }
        let ref = firebaseManager.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        ref.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let welf = self else {
                return
            }
            if let error = error {
                welf.loginStatusMeesage = "Failed to save image \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    welf.loginStatusMeesage = "Failed to retreive download URL\(error)"
                    return
                }
                welf.loginStatusMeesage = "Succes! \(url?.absoluteString ?? "")"
                guard let url = url else { return }
                welf.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = firebaseManager.getCurrentFirebaseUser()?.uid else { return }
        let chatUser = ChatUser(id: uid,
                                email: email,
                                profileImageUrl: imageProfileUrl.absoluteString)
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
