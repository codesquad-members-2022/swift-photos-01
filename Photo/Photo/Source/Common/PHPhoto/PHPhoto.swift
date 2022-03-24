//
//  PHPhoto.swift
//  Photo
//
//  Created by seongha shin on 2022/03/24.
//

import Foundation
import Photos
import UIKit

class PHPhoto {
    
    enum PermissionError: Error {
        case permissionError
    }
    
    enum PHPhotoError: Error {
        case loadFailed
    }
    
    static func authorization(completion: @escaping (Result<(Void), PermissionError>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                completion(.success(()))
            default:
                completion(.failure(.permissionError))
                break;
            }
        }
    }
    
    static func fetchAsset() -> PHFetchResult<PHAsset> {
        PHAsset.fetchAssets(with: nil)
    }
    
    static func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, completion: @escaping (Result<UIImage, PHPhotoError>) -> Void) {
        PHCachingImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: nil) { image, _ in
            guard let image = image else {
                completion(.failure(.loadFailed))
                return
            }
            completion(.success(image))
        }
    }
    
    static func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>)->Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { isSuccess, error in
            if isSuccess {
                completion(.success(()))
            } else {
                guard let error = error else {
                    return
                }
                completion(.failure(error))
            }
        }
        
    }
}
