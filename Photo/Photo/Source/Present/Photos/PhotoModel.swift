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
    
    private var phAsset: PHFetchResult<PHAsset>?
    
    var count: Int {
        guard let count = self.phAsset?.count else {
            return 0
        }
        return count
    }
    
    init() {
        action.fetchAssets.sink(to: {
            self.phAsset = PHAsset.fetchAssets(with: nil)
            self.state.fetchedAssets.accept(())
        })
        
        action.loadImage.sink(to: { index, size in
            guard let photoAsset = self.phAsset,
                  index < photoAsset.count else {
                return
            }
            PHCachingImageManager.default().requestImage(for: photoAsset[index], targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
                self.state.loadedImage.accept((index, image))
            }
        })
    }
}
