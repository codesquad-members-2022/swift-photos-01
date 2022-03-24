//
//  JsonParser.swift
//  Photo
//
//  Created by seongha shin on 2022/03/24.
//

import Foundation
import Combine

class JsonParser {
    
    enum JsonError: Error {
        case error
        static func parsing(description: String) -> JsonError {
            error
        }
    }
    
    static func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, JsonParser.JsonError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
            .parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
