//
//  DoodleViewController.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit

class DoodleViewController: UICollectionViewController {
    enum Constants {
        static let collectionCellSize = CGSize(width: 110, height: 50)
        static let minimumLineSpacing: CGFloat = 10
        static let minimumInteritemSpacing: CGFloat = 10
        static let cellIdentifier = "cell"
    }
    
    static var flowLayout: UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = Constants.collectionCellSize
        flowLayout.minimumLineSpacing = Constants.minimumLineSpacing
        flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        
        return flowLayout
    }
    
    let navigationBarClose: UIButton = {
        let barButton = UIButton()
        barButton.setTitle("Close", for: .normal)
        barButton.setTitleColor(.systemBlue, for: .normal)
        barButton.titleLabel?.font = .systemFont(ofSize: 20)
        return barButton
    }()
    
    private let doodleModel = DoodleModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        attribute()
        layout()
        
        doodleModel.action.loadJson.accept(())
    }
    
    private func bind() {
        doodleModel.state.loadedDoodles.sink(to: {
            self.collectionView.reloadData()
        })
        
        navigationBarClose.addAction(UIAction{ _ in
            self.dismiss(animated: true, completion: nil)
        }, for: .touchUpInside)
    }
    
    private func attribute() {
        self.title = "Doodle"
        self.view.backgroundColor = .white
        
        self.collectionView.backgroundColor = .systemGray4
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationBarClose)
    }
    
    private func layout() {
    }
}

extension DoodleViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.doodleModel.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? PhotosCollectionCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .random
//        cell.setImage(nil)
//        self.photoModel.photo.action.loadImage.accept((indexPath.item, Constants.collectionCellSize))
        return cell
    }
}
