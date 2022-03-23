//
//  DoodleModel.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit
import Photos

class DoodleModel {
    struct Action {
        let loadJson = Publish<Void>()
        let loadImage = Publish<Int>()
        let saveImage = Publish<Int>()
    }
    
    struct State {
        let loadedDoodles = Publish<Void>()
        let loadedImage = Publish<(Int, UIImage?)>()
        let savedImage = Publish<String>()
    }
    
    let action = Action()
    let state = State()
    
    private var doodles: [Doodle] = []
    private var imageCache = NSCache<NSString, UIImage>()
    
    var count: Int {
        return doodles.count
    }
    
    init() {
        action.loadJson.sink(to: {
            guard let fileLocation = Bundle.main.url(forResource: "doodle", withExtension: "json"),
                  let data = try? Data(contentsOf: fileLocation),
                  let doodles = try? JSONDecoder().decode(Doodles.self, from: data) else {
                      return
                  }
            
            self.doodles = doodles.data
            self.state.loadedDoodles.accept(())
        })
        
        action.loadImage.sink(to: { index in
            let doodle = self.doodles[index]
            
            if let cacheImage = self.imageCache.object(forKey: doodle.title as NSString) {
                self.state.loadedImage.accept((index, cacheImage))
                return
            }
            
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: doodle.imageUrl) else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
                self.state.loadedImage.accept((index, image))
                self.imageCache.setObject(image, forKey: doodle.title as NSString)
            }
        })
        
        action.saveImage.sink(to: { index in
            let doodle = self.doodles[index]
            guard let image = self.imageCache.object(forKey: doodle.title as NSString) else {
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { isSuccess, error in
                if isSuccess {
                    self.state.savedImage.accept("이미지를 저장했습니다")
                }
            }
        })
    }
}
