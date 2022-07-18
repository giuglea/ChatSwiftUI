//
//  GalleryViewModel.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.07.2022.
//

import Foundation

final class GalleryViewModel: ObservableObject {
    private let firebaseManager: FirebaseManager
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
    }
}
