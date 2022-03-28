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
        var viewDidLoad = PassthroughSubject<Void, Never>()
        var loadImage = PassthroughSubject<(Int, CGSize), Never>()
        var changeAssets = PassthroughSubject<PHChange, Never>()
        var selectedImages = PassthroughSubject<[Int], Never>()
        var makeVideo = PassthroughSubject<[Int], Never>()
    }
    
    struct State {
        var collectionReloadData = PassthroughSubject<Void, Never>()
        var loadedImage = PassthroughSubject<(Int, UIImage?), Never>()
        var insertAssets = PassthroughSubject<Int, Never>()
        var doneButtonEnabled = PassthroughSubject<Bool, Never>()
    }
    
    var cancellables = Set<AnyCancellable>()
    let action = Action()
    let state = State()
    
    private var featchResult: PHFetchResult<PHAsset>?
    
    var count: Int {
        featchResult?.count ?? 0
    }
    
    init() {
        action.viewDidLoad
            .sink {
                self.featchResult = PHPhoto.fetchAsset()
                self.state.collectionReloadData.send()
                self.state.doneButtonEnabled.send(false)
            }.store(in: &cancellables)
        
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
                    self.state.insertAssets.send((changes.fetchResultAfterChanges.count - 1))
                }
            }.store(in: &cancellables)
        
        action.selectedImages
            .map { $0.count >= 3 }
            .sink(receiveValue: self.state.doneButtonEnabled.send(_:))
            .store(in: &cancellables)
        
        action.makeVideo
            .sink {
              print($0)
            }.store(in: &cancellables)
    }
}
