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
    
    private var doodles: Doodles?
    
    var count: Int {
        guard let doodles = self.doodles else {
            return 0
        }
        return doodles.data.count
    }
    
    init() {
    }
}
