//
//  Publisher.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import Combine

class Publish<T> {
    @Published private var publishValue: T?
    private var cancellable: Cancellable?
    private var observers: [(T)->Void] = []
    
    init() {
        cancellable = $publishValue.sink { value in
            guard let value = value else { return }
            self.observers.forEach {
                $0(value)
            }
        }
    }
    
    init(value: T) {
        self.publishValue = value
        cancellable = $publishValue.sink { value in
            guard let value = value else { return }
            self.observers.forEach {
                $0(value)
            }
        }
    }
    
    func sink(to action: @escaping (T) -> Void) {
        observers.append(action)
    }
    
    func accept(_ value: T) {
        self.publishValue = value
    }
}
