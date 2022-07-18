//
//  LoginManager.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import Firebase

protocol LogInManager {
    func loginUser(withEmail email: String, password: String,  completion: @escaping (_ error: Error?) -> ())
    func createNewAccount(withEmail email: String, password: String, completion: @escaping (_ error: Error?) -> ())
}

final class LogInManagerImplementation: LogInManager {
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
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
