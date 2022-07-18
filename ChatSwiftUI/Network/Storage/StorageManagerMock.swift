//
//  StorageManagerMock.swift
//  ChatSwiftUI
//
//  Created by Tzy on 16.07.2022.
//

import Foundation
import UIKit

final class StorageManagerMock: StorageManager {
    func persistImageToStorage(image: UIImage?, to path: String, completion: @escaping (String?, Error?) -> ()) {
        completion("", nil)
    }
}
