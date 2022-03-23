//
//  ViewController.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import UIKit
import Photos

class PhotosViewController: UIViewController {
    enum Constants {
        static let collectionCellSize = CGSize(width: 100, height: 100)
        static let minimumLineSpacing: CGFloat = 10
        static let minimumInteritemSpacing: CGFloat = 10
        static let cellIdentifier = "cell"
    }
        
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = Constants.collectionCellSize
        flowLayout.minimumLineSpacing = Constants.minimumLineSpacing
        flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        return collection
    }()
    
    let navigationBarAdd: UIButton = {
        let barButton = UIButton()
        barButton.setTitle("+", for: .normal)
        barButton.setTitleColor(.systemBlue, for: .normal)
        barButton.titleLabel?.font = .systemFont(ofSize: 20)
        return barButton
    }()
    
    private let photoModel = PhotoModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        attribute()
        layout()
        
        photoModel.action.fetchAssets.accept(())
    }
    
    private func bind() {
        photoBind()
        navigationBind()
        
        PHPhotoLibrary.shared().register(self)
        collectionView.dataSource = self
    }
    
    private func photoBind() {
        photoModel.state.fetchedAssets.sink(to: { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()                
            }
        })
        
        photoModel.state.loadedImage.sink(to: { index, image in
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotosCollectionCell else {
                return
            }
            
            cell.setImage(image)
        })
    }
    
    private func navigationBind() {
        navigationBarAdd.addAction(UIAction{ _ in
            let doodleViewController = DoodleViewController(collectionViewLayout: DoodleViewController.flowLayout)
            let rootViewcontroller = UINavigationController(rootViewController: doodleViewController)
            rootViewcontroller.modalPresentationStyle = .fullScreen
            self.navigationController?.present(rootViewcontroller, animated: true)
        }, for: .touchUpInside)
        
    }
    
    private func attribute() {
        self.title = "Photos"
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.navigationBarAdd)
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
        self.photoModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? PhotosCollectionCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .random
        cell.setImage(nil)
        self.photoModel.action.loadImage.accept((indexPath.item, Constants.collectionCellSize))
        return cell
    }
}

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.photoModel.action.fetchAssets.accept(())
    }
}
