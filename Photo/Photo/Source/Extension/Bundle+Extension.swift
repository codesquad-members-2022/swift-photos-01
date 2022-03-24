//
//  Bundel.swift
//  Photo
//
//  Created by seongha shin on 2022/03/24.
//

import Foundation

extension Bundle {
        
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T? {
        guard let url = self.url(forResource: file, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let decodeData = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        
        return decodeData
    }
}
