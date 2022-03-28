//
//  Bundel.swift
//  Photo
//
//  Created by seongha shin on 2022/03/24.
//

import Foundation

extension Data {
        
    func decode<T: Decodable>(_ type: T.Type) -> T? {
        guard let decodeData = try? JSONDecoder().decode(T.self, from: self) else {
            return nil
        }
        
        return decodeData
    }
}
