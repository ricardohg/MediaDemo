//
//  ViewController.swift
//  MediaDemo
//
//  Created by ricardo hernandez  on 7/17/17.
//  Copyright © 2017 ricardo. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
}

class ViewController: UIViewController {
    
    fileprivate let picker = UIImagePickerController()
    fileprivate let videoPicker = UIImagePickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageUrls: [URL] = []
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.videoPicker.delegate = self
    }


    @IBAction func showPhotos(_ sender: UIButton) {
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func showVideos(_ sender: UIButton) {
        self.videoPicker.mediaTypes = [kUTTypeMovie, kUTTypeAVIMovie, kUTTypeVideo, kUTTypeMPEG4] as [String]
        self.present(self.videoPicker, animated: true, completion: nil)
    }
    
    fileprivate func fetchImages(for urls:[URL], images: @escaping ([UIImage]) -> () ) {

        let fetchResults = PHAsset.fetchAssets(withALAssetURLs: urls, options: nil)
        
        var tempImages: [UIImage] = []
        fetchResults.enumerateObjects(using: { photo, count, _ in
            PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize , contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                if let im = image {
                    tempImages.append(im)
                    if count == fetchResults.count-1 {
                        images(tempImages)
                    }
                }
            })
        })
        
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let url = info[UIImagePickerControllerReferenceURL] as? NSURL {
            self.imageUrls.append(url as URL)
        }
        
        self.picker.dismiss(animated: true, completion: nil)
        self.videoPicker.dismiss(animated: true, completion: nil)
        
        self.fetchImages(for: self.imageUrls) { images in
            self.images = images
            self.collectionView.reloadData()
            
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        cell.image.image = self.images[indexPath.row]
        return cell
    }
}


