//
//  FirebaseManagerMock.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import Firebase

class FirebaseManagerMock: FirebaseManagerBase {
    func getCurrentFirebaseUser() -> User? {
        nil
    }
    
    func getCurrentFirebaseUserId() -> String? {
       "f35b21"
    }
    
    func getCurrentUser() -> ChatUser? {
        ChatUser(id: "f35b21", email: "mai@mailinator.com", profileImageUrl: "")
    }
}
