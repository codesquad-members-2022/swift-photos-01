//
//  Model.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import Photos
import UIKit
import Combine

class PhotoModel {
    
    struct Action {
        var fetchAssets = PassthroughSubject<Void, Never>()
        var loadImage = PassthroughSubject<(Int, CGSize), Never>()
    }
    
    struct State {
        var fetchedAssets = CurrentValueSubject<PHFetchResult<PHAsset>?, Never>(nil)
        var loadedImage = PassthroughSubject<(Int, UIImage?), Never>()
    }
    
    var cancellables = [AnyCancellable]()
    let action = Action()
    let state = State()
    
    init() {
        action.fetchAssets
            .sink { _ in
                let phAsset = PHPhoto.fetchAsset()
                self.state.fetchedAssets.send(phAsset)
            }
            .store(in: &cancellables)
        
        action.loadImage
            .combineLatest(state.fetchedAssets)
            .sink { loadData, phAsset in
                guard let photoAsset = phAsset,
                      loadData.0 < photoAsset.count else {
                          return
                      }
                
                PHPhoto.requestImage(for: photoAsset[loadData.0], targetSize: loadData.1, contentMode: .aspectFill) { result in
                    switch result {
                    case .success(let image):
                        self.state.loadedImage.send((loadData.0, image))
                    case .failure(let error):
                        break
                    }
                }
            }.store(in: &cancellables)
    }
}
