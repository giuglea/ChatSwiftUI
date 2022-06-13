//
//  SettingsViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import Foundation

enum Setting: Int, CaseIterable, Identifiable {
    var id: Int {
        return self.rawValue
    }
    
    case language = 0
    case changePassword = 1
    case logout = 2
    
    var title: String {
        switch self {
        case .language:
            return "Change language"
        case .changePassword:
            return "Change password"
        case .logout:
            return "Log out"
        }
    }
}

final class SettingsViewModel: ObservableObject {
    
    @Published var settings = Setting.allCases
    @Published var chatUser: ChatUser?
    @Published var shouldSignOut = false
    
    let firebaseManager: FirebaseManager
    var onSignOut: (() -> ())?
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
    }
    
    func didPressSetting(_ setting: Setting) {
        switch setting {
        case .language:
            break
        case .changePassword:
            break
        case .logout:
            chatUser = nil
            onSignOut?()
        }
    }
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var displayVersion: String {
        "App version: \(appVersion ?? "")"
    }
}
