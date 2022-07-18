//
//  FirebaseManager.swift
//  ChatSwiftUI
//
//  Created by Tzy on 17.11.2021.
//

import Firebase
import UIKit

protocol FirebaseManager {
    func getCurrentFirebaseUser() -> User?
    func getCurrentUser() -> ChatUser?
    func generateNewChatId() -> String
    func persistImageToStorage(image: UIImage?,
                               completion: @escaping (String?, Error?) -> ())
    func getCurrentFirebaseUserId() -> String?
    func sendResetPassword()

    var firestore: Firestore { get }
    
    func loginUser(withEmail email: String, password: String,  completion: @escaping (_ error: Error?) -> ())
    func createNewAccount(withEmail email: String, password: String, completion: @escaping (_ error: Error?) -> ())
    
    func fetchRecentMessages(for email: String) -> Query
    func fetchAllUsers() -> Query
}

final class FirebaseManagerImplementation: NSObject,
                                           FirebaseManager {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    var currentUser: ChatUser?
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
    func fetchAllUsers() -> Query {
        firestore
            .collection(FirebaseConstants.Collection.users)
    }
    
    func fetchRecentMessages(for email: String) -> Query {
        firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .whereField(FirebaseConstants.Group.participantsNames, arrayContains: email)
    }
    
    func generateNewChatId() -> String {
        firestore.collection(FirebaseConstants.Group.groupId).document().documentID
    }
    
    func getCurrentFirebaseUser() -> User? {
        auth.currentUser
    }
    
    func getCurrentFirebaseUserId() -> String? {
        auth.currentUser?.uid
    }
    
    func getCurrentUser() -> ChatUser? {
        currentUser
    }
    
    func persistImageToStorage(image: UIImage?, completion: @escaping (String?, Error?) -> ()) {
        guard let uid = getCurrentFirebaseUser()?.uid else {
            return
        }
        
        let ref = storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: FirebaseConstants.Compression.imageCompression) else {
            return
        }
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let url = url else {
                    completion(nil, error)
                    return
                }
                completion(url.absoluteString, nil)
            }
        }
    }
    
    func sendResetPassword() {
        guard let email = currentUser?.email else {
            return
        }
        auth.sendPasswordReset(withEmail: email)
    }
    
    func loginUser(withEmail email: String, password: String,  completion: @escaping (_ error: Error?) -> ()) {
        auth.signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    func createNewAccount(withEmail email : String, password: String, completion: @escaping (_ error: Error?) -> ()) {
        auth.createUser(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
}
