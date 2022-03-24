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
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    var delegate: DoodleCollectionCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
        layout()
        
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bind()
        layout()
        self.isUserInteractionEnabled = true
    }
    
    private func bind() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(targetViewDidPress))
        longPressGestureRecognizer.minimumPressDuration = 1
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc
    private func targetViewDidPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let senderView = sender.view,
              let superView = sender.view?.superview else {
                  return
              }
        
        senderView.becomeFirstResponder()
        let saveMenuItem = UIMenuItem(title: "Save", action: #selector(SaveMenuItemTapped))
        UIMenuController.shared.menuItems = [saveMenuItem]
        UIMenuController.shared.showMenu(from: superView, rect: senderView.frame)
        
    }
    
    @objc
    private func SaveMenuItemTapped() {
        self.delegate?.save(self)
    }
    
    private func layout() {
        self.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
}
