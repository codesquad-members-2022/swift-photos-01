//
//  Toast.swift
//  Photo
//
//  Created by seongha shin on 2022/03/23.
//

import Foundation
import UIKit

extension UIViewController {
    func showToast(message: String, font: UIFont = .systemFont(ofSize: 20)) {
        var size = NSString(string: message).size(withAttributes: [NSAttributedString.Key.font: font])
        size.width += 20
        size.height += 10
        
        let originX = (self.view.frame.size.width / 2) - (size.width / 2)
        let originY = self.view.frame.size.height - 150
        let label = UILabel(frame: CGRect(x: originX , y: originY, width: size.width, height: size.height))
        
        label.backgroundColor = .darkGray
        
        label.text = message
        label.font = font
        label.textColor = .white
        label.textAlignment = .center
        
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        
        self.view.addSubview(label)
        
        UIView.animate(withDuration: 3.0, delay: 0.2, options: .curveEaseInOut, animations: {
            label.alpha = 0
        }, completion: { _ in
            label.removeFromSuperview()
        })
    }
}
