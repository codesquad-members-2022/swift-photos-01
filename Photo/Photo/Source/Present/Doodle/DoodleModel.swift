//
//  DoodleModel.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation

class DoodleModel {
    struct Action {
        let loadJson = Publish<Void>()
    }
    
    struct State {
        let loadedDoodles = Publish<Void>()
    }
    
    let action = Action()
    let state = State()
    
    private var doodles: [Doodle] = []
    
    var count: Int {
        return doodles.count
    }
    
    init() {
        action.loadJson.sink(to: {
            guard let fileLocation = Bundle.main.url(forResource: "doodle", withExtension: "json") else { return }

                do {
                    let data = try Data(contentsOf: fileLocation)
                    let doodles = try JSONDecoder().decode(Doodles.self, from: data)
                    self.doodles = doodles.data
                    self.state.loadedDoodles.accept(())
                } catch {

                }
        })
    }
}
