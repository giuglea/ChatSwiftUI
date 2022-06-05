//
//  FirebaseManager.swift
//  ChatSwiftUI
//
//  Created by Tzy on 17.11.2021.
//

import Firebase

protocol FirebaseManager {
    func getCurrentFirebaseUser() -> User?
    func getCurrentUser() -> ChatUser?

    var storage: Storage { get }
    var firestore: Firestore { get }
    var auth: Auth { get }
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
    
    func getCurrentFirebaseUser() -> User? {
        return auth.currentUser
    }
    
    func getCurrentUser() -> ChatUser? {
        return currentUser
    }
}
