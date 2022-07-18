//
//  FirebaseManagerBase.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import Firebase

protocol FirebaseManagerBase {
    func getCurrentFirebaseUser() -> User?
    func getCurrentUser() -> ChatUser?
    func getCurrentFirebaseUserId() -> String?
}

class FirebaseManagerBaseImplementation: FirebaseManagerBase {
    let auth: Auth
    var currentUser: ChatUser?
    
    init(auth: Auth = Auth.auth(),
         currentUser: ChatUser?) {
        self.auth = auth
        self.currentUser = currentUser
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
}
