//
//  Color+Exteionsoin.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import UIKit

extension UIColor {
    static var random: UIColor {
        let r = Int.random(in: 10...255)
        let g = Int.random(in: 10...255)
        let b = Int.random(in: 10...255)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
}
