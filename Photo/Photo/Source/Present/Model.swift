//
//  Model.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import Photos
import UIKit

class Model {
    struct Photo {
        struct Action {
            let fetchAssets = Publish<Void>()
            let loadImage = Publish<(Int, CGSize)>()
        }
        
        struct State {
            let fetchedAssets = Publish<Void>()
            let loadedImage = Publish<(Int, UIImage?)>()
        }
        
        let action = Action()
        let state = State()
    }
    
    let photo = Photo()
    
    private var photoAsset: PHFetchResult<PHAsset>?
    
    var count: Int {
        guard let asset = self.photoAsset else {
            return 0
        }
        return asset.count
    }
    
    init() {
        bind()
    }
    
    private func bind() {
        photo.action.fetchAssets.sink(to: {
            self.photoAsset = PHAsset.fetchAssets(with: nil)
            self.photo.state.fetchedAssets.accept(())
        })
        
        photo.action.loadImage.sink(to: { index, size in
            guard let photoAsset = self.photoAsset,
                  index < photoAsset.count else {
                return
            }
            PHCachingImageManager.default().requestImage(for: photoAsset[index], targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
                self.photo.state.loadedImage.accept((index, image))
            }
        })
    }
}
