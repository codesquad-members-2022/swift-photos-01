//
//  DoodleModel.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit
import Photos
import Combine

class DoodleModel {
    struct Action {
        var loadJson = PassthroughSubject<Void, Never>()
        var loadImage = PassthroughSubject<Int, Never>()
        var saveImage = PassthroughSubject<Int, Never>()
    }

    struct State {
        var loadedDoodles = PassthroughSubject<Void, Never>()
        var loadedImage = PassthroughSubject<(Int, UIImage?), Never>()
        var savedImage = PassthroughSubject<String, Never>()
    }
    
    var cancellables = [AnyCancellable]()
    let action = Action()
    let state = State()

    private var doodles: [Doodle] = []
    private var imageCache = NSCache<NSString, UIImage>()

    var count: Int {
        return doodles.count
    }

    init() {
        action.loadJson
            .map{Bundle.main.decode(Doodles.self, from: "doodle.json")}
            .sink { doodles in
                guard let doodles = doodles else {
                    return
                }
                self.doodles = doodles.data
                self.state.loadedDoodles.send()
            }.store(in: &cancellables)
        
        action.loadImage
            .map { index in
                (index, self.doodles[index])
            }
            .filter { index, doodle in
                if let cacheImage = self.imageCache.object(forKey: doodle.title as NSString) {
                    self.state.loadedImage.send((index, cacheImage))
                    return false
                }
                return true
            }
            .sink { index, doodle in
                URLSession.shared.downloadImage(for: doodle.imageUrl) { image in
                    guard let image = image else {
                        return
                    }
                    self.state.loadedImage.send((index, image))
                    self.imageCache.setObject(image, forKey: doodle.title as NSString)
                }
            }.store(in: &cancellables)
        
        action.saveImage
            .sink { index in
            let doodle = self.doodles[index]
            guard let image = self.imageCache.object(forKey: doodle.title as NSString) else {
                return
            }
            
            PHPhoto.saveImage(image) { result in
                switch result {
                case .success(()):
                    self.state.savedImage.send("이미지를 저장했습니다")
                case .failure(let error):
                    break
                }
            }
        }.store(in: &cancellables)
    }
}
