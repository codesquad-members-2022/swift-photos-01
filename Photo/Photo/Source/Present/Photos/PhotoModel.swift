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
        var changeAssets = PassthroughSubject<PHChange, Never>()
    }
    
    struct State {
        var fetchedAssets = PassthroughSubject<Void, Never>()
        var loadedImage = PassthroughSubject<(Int, UIImage?), Never>()
        var insertAssets = PassthroughSubject<(Int, PHAsset), Never>()
    }
    
    var cancellables = Set<AnyCancellable>()
    let action = Action()
    let state = State()
    
    private var featchResult: PHFetchResult<PHAsset>?
    
    var count: Int {
        featchResult?.count ?? 0
    }
    
    init() {
        action.fetchAssets
            .sink { _ in
                self.featchResult = PHPhoto.fetchAsset()
                self.state.fetchedAssets.send()
            }
            .store(in: &cancellables)
        
        action.loadImage
            .sink { index, size in
                guard let photoAsset = self.featchResult,
                      index < photoAsset.count else {
                          return
                      }
                
                PHPhoto.requestImage(for: photoAsset[index], targetSize: size, contentMode: .aspectFill) { result in
                    switch result {
                    case .success(let image):
                        self.state.loadedImage.send((index, image))
                    case .failure(let error):
                        break
                    }
                }
            }.store(in: &cancellables)
        
        action.changeAssets
            .sink { changeInstance in
                guard let fetchResult = self.featchResult,
                      let changes = changeInstance.changeDetails(for: fetchResult) else {
                          return
                      }
                
                self.featchResult = changes.fetchResultAfterChanges
                
                changes.insertedObjects.forEach { asset in
                    self.state.insertAssets.send((changes.fetchResultAfterChanges.count - 1, asset))
                }
            }.store(in: &cancellables)
    }
}
