//
//  PhotoSelectorController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/03/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerCellId = "headerCellId"
    var images = [UIImage]()
    var imageAssets = [PHAsset]()
    var selectedAsset: PHAsset?
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //for UICollectionViewController
        collectionView?.backgroundColor = .white
        //for UIViewController
        //view.backgroundColor = .yellow
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerCellId)
        
        fetchPhotos()
    }
    
    private func fetchPhotos(){
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 24
            let sortByCreationDate = NSSortDescriptor(key: "creationDate", ascending: true)
            fetchOptions.sortDescriptors = [sortByCreationDate]
            
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            DispatchQueue.global(qos: .background).async {
                allPhotos.enumerateObjects { (asset, idx, stop) in
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300)
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, info) in
                        if let img = image {
                            self.images.append(img)
                            self.imageAssets.append(asset)
                            
                            if self.selectedAsset == nil {
                                self.selectedAsset = asset
                                self.selectedImage = img
                            }
                            
                            if idx == allPhotos.count - 1 {
                                DispatchQueue.main.async {
                                    self.collectionView?.reloadData()
                                }
                            }
                        }
                    })
                }
            }
            
        } else {
            let alertController = UIAlertController (title: "Photo Library Unavailable", message: "Please check to see if device settings doesn't allow photo library access", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
                let settingsUrl = URL(string:UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedAsset = self.imageAssets[indexPath.item]
        self.selectedImage = self.images[indexPath.item]
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.image = self.images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId, for: indexPath) as! PhotoHeaderCell
        
        if let asset = self.selectedAsset {
            let imageManger = PHImageManager()
            let targetSize = CGSize(width: 600, height: 600)
            imageManger.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, info) in
                view.image = image
            }
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    private func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    //delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //handlers
    @objc private func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleNext(){
        let sharePhotoController = SharePhotoController()
        if let image = self.selectedImage {
            sharePhotoController.image = image
        }
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
}
