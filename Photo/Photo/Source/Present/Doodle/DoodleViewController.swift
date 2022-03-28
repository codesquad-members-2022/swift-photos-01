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
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    var cancellables = Set<AnyCancellable>()
    private var doodleModel = DoodleModel()
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll()
    }
    
    deinit {
        self.doodleModel.cancellables.forEach{ $0.cancel()}
    }
    
    private func bind() {
        doodleModel.state.loadedDoodles
            .sink { _ in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }.store(in: &cancellables)

        doodleModel.state.savedImage
            .sink { message in
                DispatchQueue.main.async {
                    self.showToast(message: message)
                }
            }.store(in: &cancellables)
        
        doodleModel.state.loadedImage
            .sink { index in
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
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
        cancellables.forEach{ $0.cancel()}
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func targetViewDidPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let senderView = sender.view,
              let cell = senderView as? UICollectionViewCell,
              let indexPath = self.collectionView.indexPath(for: cell) else {
                  return
              }
        
        self.doodleModel.action.selectIndex.send(indexPath.item)
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "Save", action: #selector(save))
        ]
        UIMenuController.shared.showMenu(from: self.view, rect: senderView.frame)
    }
    
    @objc
    private func save() {
        self.doodleModel.action.saveImage.send()
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
        
        guard let imageUrl = self.doodleModel[indexPath.item],
              let data = try? Data(contentsOf: imageUrl),
              let image = UIImage(data: data) else {
                  return UICollectionViewCell()
              }
        
        cell.backgroundColor = .random
        cell.setImage(image)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(targetViewDidPress))
        gestureRecognizer.minimumPressDuration = 1
        cell.addGestureRecognizer(gestureRecognizer)
        return cell
    }
}
