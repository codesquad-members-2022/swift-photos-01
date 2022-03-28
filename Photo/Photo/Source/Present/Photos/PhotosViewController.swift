//
//  ViewController.swift
//  Photo
//
//  Created by seongha shin on 2022/03/21.
//

import Foundation
import UIKit
import Photos
import Combine

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
        collection.allowsMultipleSelection = true
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
    
    let navigationBarDone: UIButton = {
        let barButton = UIButton()
        barButton.setTitle("Done", for: .normal)
        barButton.setTitleColor(.systemBlue, for: .normal)
        barButton.setTitleColor(.systemGray4, for: .disabled)
        barButton.titleLabel?.font = .systemFont(ofSize: 20)
        barButton.isEnabled = false
        return barButton
    }()
    
    var cancellables = Set<AnyCancellable>()
    private let photoModel = PhotoModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        attribute()
        layout()
        
        PHPhoto.authorization { result in
            switch result {
            case .success(()):
                PHPhotoLibrary.shared().register(self)
                self.photoModel.action.viewDidLoad.send()
            case .failure(let error):
                exit(0)
            }
        }
    }
    
    private func bind() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        photoModel.state.collectionReloadData
            .sink {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }.store(in: &cancellables)

        photoModel.state.loadedImage
            .sink { index, image in
                DispatchQueue.main.async {
                    guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as?
                            PhotosCollectionCell else {
                                return
                            }
                    cell.setImage(image)
                }
            }.store(in: &cancellables)
        
        photoModel.state.insertAssets
            .sink { index in
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                }
            }.store(in: &cancellables)
        
        photoModel.state.doneButtonEnabled
            .sink { isEnabled in
                DispatchQueue.main.async {
                    self.navigationBarDone.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
        
        navigationBarAdd.addAction(UIAction{ _ in
            let doodleViewController = DoodleViewController(collectionViewLayout: DoodleViewController.flowLayout)
            let rootViewcontroller = UINavigationController(rootViewController: doodleViewController)
            rootViewcontroller.modalPresentationStyle = .fullScreen
            self.navigationController?.present(rootViewcontroller, animated: true)
        }, for: .touchUpInside)
        
        navigationBarDone.addAction(UIAction { _ in
            guard let selectedItems = self.collectionView.indexPathsForSelectedItems else {
                return
            }
            self.photoModel.action.makeVideo.send(selectedItems.map{ $0.item })
        }, for: .touchUpInside)
    }
    
    private func attribute() {
        self.title = "Photos"
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.navigationBarAdd)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.navigationBarDone)
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

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell else {
            return
        }
        cell.isSelected = true
        sendSelectedItems(collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell else {
            return
        }
        cell.isSelected = false
        sendSelectedItems(collectionView: collectionView)
    }
    
    private func sendSelectedItems(collectionView: UICollectionView) {
        let selectedItems = collectionView.indexPathsForSelectedItems?.compactMap{ $0.item }
        self.photoModel.action.selectedImages.send(selectedItems ?? [])
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
        cell.setImage(nil)
        self.photoModel.action.loadImage.send((indexPath.item, Constants.collectionCellSize))
        return cell
    }
}

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.photoModel.action.changeAssets.send(changeInstance)
    }
}

extension PhotosViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
}
