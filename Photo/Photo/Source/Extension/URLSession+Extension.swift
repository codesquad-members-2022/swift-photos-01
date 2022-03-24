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
                if let error = self.checkResponse(response) {
                    throw error
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func downloadImagePublisher(for url: URL) -> AnyPublisher<UIImage?, Never> {
        self.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data)}
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    private func checkResponse(_ response: URLResponse?) -> Error? {
        if let response = response as? HTTPURLResponse,
           (200..<300).contains(response.statusCode) == false {
            return SessionError.statusCode(response)
        }
        return nil
    }
}
