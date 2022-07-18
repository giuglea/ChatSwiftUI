//
//  LoginManagerMock.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation

final class LogInManagerMock: FirebaseManagerMock, LogInManager {
    func loginUser(withEmail email: String, password: String,  completion: @escaping (_ error: Error?) -> ()) {
        completion(nil)
    }
    
    func createNewAccount(withEmail email : String, password: String, completion: @escaping (_ error: Error?) -> ()) {
        completion(nil)
    }
}
