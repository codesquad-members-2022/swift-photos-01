//
//  URLSession+Extension.swift
//  Photo
//
//  Created by seongha shin on 2022/03/24.
//

import Foundation
import Combine
import UIKit

extension URLSession {
    enum ResponseError: Error {
        case statusCode(HTTPURLResponse)
    }
    
    func jsonDecoder<T: Decodable>(_ type: T.Type, for url: URL) -> AnyPublisher<T, Error> {
        self.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let error = self.checkResponse(response) {
                    throw error
                }
                return data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func downloadImages(urls: [URL], completion: @escaping (URL?) -> Void) {
        urls.forEach {
            downloadImage(url: $0, completion: completion)
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: url) { url, response, error in
            completion(url)
        }.resume()
    }
    
    private func checkResponse(_ response: URLResponse?) -> ResponseError? {
        if let response = response as? HTTPURLResponse,
           (200..<300).contains(response.statusCode) == false {
            return ResponseError.statusCode(response)
        }
        return nil
    }
}
