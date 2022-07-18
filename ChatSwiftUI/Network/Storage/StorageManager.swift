//
//  StorageManager.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import UIKit
import Firebase

protocol StorageManager {
    func persistImageToStorage(image: UIImage?, to path: String, completion: @escaping (String?, Error?) -> ())
}

final class StorageManagerImplementation: StorageManager {
    private var storage: Storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
    
    func persistImageToStorage(image: UIImage?, to path: String, completion: @escaping (String?, Error?) -> ()) {
        let ref = storage.reference(withPath: path)
        guard let imageData = image?.jpegData(compressionQuality: FirebaseConstants.Compression.imageCompression) else {
            return
        }
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let url = url else {
                    completion(nil, error)
                    return
                }
                completion(url.absoluteString, nil)
            }
        }
    }
}
