////
////  FirestoreManagerMock.swift
////  ChatSwiftUI
////
////  Created by Tzy on 16.07.2022.
////
//
//import Foundation
//
//final class FirestoreManagerMock: FirestoreManager {
//    func storeUserInformation(for chatUser: ChatUser, completion: @escaping (_ error: Error?) -> ()) {
//        completion(nil)
//    }
//    func fetchAllUsers() -> Query {
//        firestore
//            .collection(FirebaseConstants.Collection.users)
//    }
//    
//    func fetchRecentMessages(for email: String) -> Query {
//        firestore
//            .collection(FirebaseConstants.Collection.recentMessages)
//            .whereField(FirebaseConstants.Group.participantsNames, arrayContains: email)
//    }
//}
