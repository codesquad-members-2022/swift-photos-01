//
//  DoodleViewController.swift
//  Photo
//
//  Created by seongha shin on 2022/03/22.
//

import Foundation
import UIKit
import Combine

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
    
    var cancellables = [AnyCancellable]()
    private let doodleModel = DoodleModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        attribute()
        
        createNavigationButton()
        doodleModel.action.loadJson.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.view.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.barTintColor = .systemGray6
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    private func bind() {
        doodleModel.state.loadedDoodles
            .sink {
                self.collectionView.reloadData()
            }.store(in: &cancellables)

        doodleModel.state.loadedImage
            .sink { index, image in
                DispatchQueue.main.async {
                    guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as?
                            DoodleCollectionCell else {
                                return
                            }
                    cell.setImage(image)
                }
            }.store(in: &cancellables)

        doodleModel.state.savedImage
            .sink { message in
                DispatchQueue.main.async {
                    self.showToast(message: message)
                }
            }.store(in: &cancellables)
    }
    
    private func attribute() {
        self.title = "Doodle"
        self.view.backgroundColor = .white
        
        self.collectionView.backgroundColor = .systemGray2
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(DoodleCollectionCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func createNavigationButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonTapped))
    }
    
    @objc
    private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DoodleViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.doodleModel.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? DoodleCollectionCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .random
        cell.delegate = self
        cell.setImage(nil)
        self.doodleModel.action.loadImage.send(indexPath.item)
        return cell
    }
}

extension DoodleViewController: DoodleCollectionCellDelegate {
    func save(_ cell: DoodleCollectionCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }

        self.doodleModel.action.saveImage.send(indexPath.item)
    }
}
