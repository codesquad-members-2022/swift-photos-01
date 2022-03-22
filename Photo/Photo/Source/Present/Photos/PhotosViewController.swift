//
//  ViewController.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import UIKit
import Photos

class PhotosViewController: UIViewController {
    enum Constants {
        static let collectionCellSize = CGSize(width: 100, height: 100)
        static let minimumLineSpacing: CGFloat = 10
        static let minimumInteritemSpacing: CGFloat = 10
    }
        
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = Constants.collectionCellSize
        flowLayout.minimumLineSpacing = Constants.minimumLineSpacing
        flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    private let model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        attribute()
        layout()
        
        model.photo.action.fetchAssets.accept(())
    }
    
    private func bind() {
        PHPhotoLibrary.shared().register(self)
        collectionView.dataSource = self
        
        model.photo.state.fetchedAssets.sink(to: {
            self.collectionView.reloadData()
        })
        
        model.photo.state.loadedImage.sink(to: { index, image in
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotosCollectionCell else {
                return
            }
            
            cell.setImage(image)
        })
    }
    
    private func attribute() {
        self.title = "Photos"
    }
    
    private func layout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 10).isActive = true
        collectionView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -10).isActive = true
    }
}

extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotosCollectionCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .random
        cell.setImage(nil)
        self.model.photo.action.loadImage.accept((indexPath.item, Constants.collectionCellSize))
        return cell
    }
}

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
