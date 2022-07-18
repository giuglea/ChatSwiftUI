//
//  FirestoreManager.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import Firebase

protocol FirestoreManager {
    func storeUserInformation(for chatUser: ChatUser, completion: @escaping (_ error: Error?) -> ())
    func fetchGroups(for email: String) -> Query
    func fetchAllUsers() -> Query
    func fetchMessages(for chatModelId: String) -> Query
    func handleSend(for chatModelId: String, with chatMessage: ChatMessage, completion: @escaping (_ error: Error?) -> ())
    func persistRecentMessage(for chatModelId: String, with chatMessage: ChatMessage, completion: @escaping (_ error: Error?) -> ())
}

final class FirestoreManagerImplementation: FirestoreManager {
    private let firestore: Firestore
    
    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    
    func storeUserInformation(for chatUser: ChatUser, completion: @escaping (_ error: Error?) -> ()) {
        guard let uid = chatUser.id else {
            return
        }
        
        try? firestore.collection(FirebaseConstants.Collection.users)
            .document(uid)
            .setData(from: chatUser) {error in
                completion(error)
            }
    }
    
    func fetchAllUsers() -> Query {
        firestore
            .collection(FirebaseConstants.Collection.users)
        
    }
    
    func fetchGroups(for email: String) -> Query {
        firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .whereField(FirebaseConstants.Group.participantsNames, arrayContains: email)
    }
    
    func fetchMessages(for chatModelId: String) -> Query {
        firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(chatModelId)
            .collection(FirebaseConstants.Collection.messages)
            .order(by: FirebaseConstants.Message.timeStamp)
    }
    
    func handleSend(for chatModelId: String, with chatMessage: ChatMessage, completion: @escaping (_ error: Error?) -> ()) {
        let document = firestore
            .collection(FirebaseConstants.Group.groupId)
            .document(chatModelId)
            .collection(FirebaseConstants.Collection.messages)
            .document()
        
        try? document.setData(from: chatMessage) { error in
            completion(error)
        }
    }
    
    func persistRecentMessage(for chatModelId: String, with chatMessage: ChatMessage, completion: @escaping (_ error: Error?) -> ()) {
        let document = firestore
            .collection(FirebaseConstants.Collection.recentMessages)
            .document(chatModelId)
        
        try? document.setData(from: chatMessage) { error in
            completion(error)
        }
    }
}


