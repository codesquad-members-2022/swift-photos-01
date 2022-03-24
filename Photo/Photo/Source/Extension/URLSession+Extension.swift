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
    enum SessionError: Error {
        case statusCode(HTTPURLResponse)
    }
    
    func jsonDecoder<T: Decodable>(for url: URL) -> AnyPublisher<T, Error> {
        self.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) == false {
                    print(response.statusCode)
                    throw SessionError.statusCode(response)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func downloadImagePublisher(for url: URL) -> AnyPublisher<UIImage?, Error> {
        self.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let response = response as? HTTPURLResponse,
                   (200..<300).contains(response.statusCode) == false {
                    throw SessionError.statusCode(response)
                }
                return data
            }
            .map { data -> UIImage? in
                guard let image = UIImage(data: data) else {
                    return nil
                }
                return image
            }
            .eraseToAnyPublisher()
    }
    
    func downloadImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        self.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse,
               (200..<300).contains(response.statusCode) == false {
                return
            }
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            completion(image)
        }.resume()
    }
}
