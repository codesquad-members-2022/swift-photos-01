//
//  Permission.swift
//  Photo
//
//  Created by seongha shin on 2022/03/23.
//

import Foundation
import Photos

enum Permission {
    static func PHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                completion()
            default:
                break;
            }
        }
    }
}
