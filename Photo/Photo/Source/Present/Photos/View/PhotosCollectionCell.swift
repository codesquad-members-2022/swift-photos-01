//
//  PhotosCollectionCell.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit
import Photos

class PhotosCollectionCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let selectView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selectedBackgroundView = selectView
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectedBackgroundView = selectView
        layout()
    }
    
    private func layout() {
        self.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
}
