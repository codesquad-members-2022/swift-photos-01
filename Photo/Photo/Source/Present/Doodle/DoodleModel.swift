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
        var saveImage = PassthroughSubject<Void, Never>()
        let selectIndex = PassthroughSubject<Int, Never>()
    }

    struct State {
        var loadedDoodles = PassthroughSubject<Void, Never>()
        var loadedImage = PassthroughSubject<Int, Never>()
        var savedImage = PassthroughSubject<String, Never>()
    }
    
    var cancellables = Set<AnyCancellable>()
    let action = Action()
    let state = State()
    
    private var doodles: [Doodle] = []

    var count: Int {
        return doodles.count
    }
    
    subscript(index: Int) -> URL? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cachesDirectory.appendingPathComponent(doodles[index].title)
    }

    init() {
        action.loadJson
            .map { _ in
                URLSession.shared.jsonDecoder([Doodle].self, for: URL(string: "https://public.codesquad.kr/jk/doodle.json")!)
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
                self.doodles = doodles
                self.state.loadedDoodles.send()
                self.cacheImage(doodles: doodles)
            }.store(in: &cancellables)
        
        //TODO: 프로젝트 내부의 파일을 가져올때 사용하는 코드
//        action.loadJson
//            .sink { doodles in
//                guard let url = Bundle.main.url(forResource: "doodle.json", withExtension: nil),
//                      let data = try? Data(contentsOf: url),
//                      let doodles = data.decode([Doodle].self) else {
//                          return
//                      }
//                self.state.loadedDoodles.send(doodles)
//            }.store(in: &cancellables)
        
        action.saveImage
            .combineLatest(self.action.selectIndex)
            .sink { _, index in
                URLSession.shared.downloadImage(url: self.doodles[index].imageUrl) { tempUrl in
                    guard let url = tempUrl,
                          let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data) else {
                        return
                    }
                    PHPhoto.saveImage(image, completion: nil)
                }
            }.store(in: &cancellables)
    }
    
    private func cacheImage(doodles: [Doodle]) {
        doodles.enumerated().forEach { index, doodle in
            URLSession.shared.downloadImage(url: doodle.imageUrl) { tempUrl in
                guard let url = tempUrl,
                      let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                    return
                }
                let destination = cachesDirectory.appendingPathComponent(doodle.title)
                
                if FileManager.default.fileExists(atPath: destination.path) {
                    try? FileManager.default.removeItem(at: destination)
                }
                try? FileManager.default.copyItem(at: url, to: destination)
                self.state.loadedImage.send(index)
            }
        }
    }
}
