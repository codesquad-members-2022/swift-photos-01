//
//  DoodleCollectionCell.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit

protocol DoodleCollectionCellDelegate {
    func save(_ cell: DoodleCollectionCell)
}

class DoodleCollectionCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var delegate: DoodleCollectionCellDelegate?
    
    private let cellButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bind()
        layout()
    }
    
    private func bind() {
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Save", image: nil) { _ in
                self.delegate?.save(self)
            }
        ])
        
        cellButton.menu = menu
    }
    
    private func layout() {
        self.addSubview(imageView)
        self.addSubview(cellButton)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        cellButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        cellButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
}
