//
//  DraftMasterViewModel.swift
//  ChatSwiftUI
//
//  Created by GigiFullSpeed on 11.04.2022.
//

import Firebase
import FirebaseFirestoreSwift

final class DraftMasterViewModel: ObservableObject {
    
    @Published var chatUser: ChatUser?
    @Published var users: [ChatUser]
    @Published var message = ""
    
    init(chatUser: ChatUser?,
         users: [ChatUser]) {
        self.chatUser = chatUser
        self.users = users
    }
    
//    func handleSend(for id: String) {
//        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
//        
//        let document = FirebaseManager.shared.firestore
//            .collection(FirebaseConstants.messages)
//            .document(fromID)
//            .collection(id)
//            .document()
//        
//        let messageData = [FirebaseConstants.fromID: fromID,
//                           FirebaseConstants.toID: id,
//                           FirebaseConstants.text: message,
//                           FirebaseConstants.timeStamp: Timestamp()] as [String: Any]
//        
//        document.setData(messageData) { error in
//            if let error = error {
//                print(error)
//            }
//        }
//        
//        let recipientMessageDocument = FirebaseManager.shared.firestore
//            .collection(FirebaseConstants.messages)
//            .document(id)
//            .collection(fromID)
//            .document()
//        
//        recipientMessageDocument.setData(messageData) { error in
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            print("Recipient saved message as well")
//        }
//    }
}
