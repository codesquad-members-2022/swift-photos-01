//
//  Model.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import Photos
import UIKit

class PhotoModel {
    struct Photo {
        struct Action {
            let fetchAssets = Publish<Void>()
            let loadImage = Publish<(Int, CGSize)>()
        }
        
        struct State {
            let fetchedAssets = Behavior<PHFetchResult<PHAsset>?>(value: nil)
            let loadedImage = Publish<(Int, UIImage?)>()
        }
        
        let action = Action()
        let state = State()
    }
    
    let photo = Photo()
    
    var count: Int {
        guard let asset = self.photo.state.fetchedAssets.value else {
            return 0
        }
        return asset.count
    }
    
    init() {
        photo.action.fetchAssets.sink(to: {
            let photoAsset = PHAsset.fetchAssets(with: nil)
            self.photo.state.fetchedAssets.accept(photoAsset)
        })
        
        photo.action.loadImage.sink(to: { index, size in
            guard let photoAsset = self.photo.state.fetchedAssets.value,
                  index < photoAsset.count else {
                return
            }
            PHCachingImageManager.default().requestImage(for: photoAsset[index], targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
                self.photo.state.loadedImage.accept((index, image))
            }
        })
    }
}
