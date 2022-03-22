//
//  Doodle.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation

struct Doodle: Decodable {
    let title: String
    let imageUrl: URL
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case title, date
        case imageUrl = "image"
    }
}

