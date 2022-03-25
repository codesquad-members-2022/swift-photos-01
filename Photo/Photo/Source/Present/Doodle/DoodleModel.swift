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
        var removeCacheData = PassthroughSubject<Void, Never>()
    }

    struct State {
        var loadedDoodles = CurrentValueSubject<[Doodle], Never>([])
        var loadedImage = PassthroughSubject<(Int, UIImage?), Never>()
        var savedImage = PassthroughSubject<String, Never>()
    }
    
    var cancellables = Set<AnyCancellable>()
    let action = Action()
    let state = State()

    private var imageCache = NSCache<NSString, UIImage>()

    var count: Int {
        return state.loadedDoodles.value.count
    }

    init() {
        action.loadJson
            .map { _ in
                URLSession.shared.jsonDecoder(for: URL(string: "https://public.codesquad.kr/jk/doodle.json")!)
            }
            .switchToLatest()
            .sink(receiveCompletion: { error in
                switch error {
                case .failure(let error):
                    Log.error("\(error)")
                case .finished:
                    Log.error("finished")
                }
            }) { doodles in
                self.state.loadedDoodles.send(doodles)
            }.store(in: &cancellables)
        
        //TODO: 프로젝트 내부의 파일을 가져올때 사용하는 코드
//        action.loadJson
//            .map{Bundle.main.decode([Doodle].self, from: "doodle.json")}
//            .sink { doodles in
//                guard let doodles = doodles else {
//                    return
//                }
//                self.state.loadedDoodles.send(doodles)
//            }.store(in: &cancellables)
        
        action.loadImage
            .combineLatest(state.loadedDoodles)
            .map { index, doodles in
                (index, doodles[index])
            }
            .filter { index, doodle in
                if let cacheImage = self.imageCache.object(forKey: doodle.title as NSString) {
                    self.state.loadedImage.send((index, cacheImage))
                    return false
                }
                return true
            }
            .sink { index, doodle in
                URLSession.shared.downloadImagePublisher(for: doodle.imageUrl)
                    .sink { image in
                        guard let image = image else {
                            return
                        }
                        self.state.loadedImage.send((index, image))
                        self.imageCache.setObject(image, forKey: doodle.title as NSString)
                    }.store(in: &self.cancellables)
            }.store(in: &cancellables)
        
        action.saveImage
            .combineLatest(state.loadedDoodles)
            .sink { index, doodles in
                let doodle = doodles[index]
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
