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
import MediaPlayer

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
}

class ViewController: UIViewController {
    
    fileprivate let picker = UIImagePickerController()
    fileprivate let videoPicker = UIImagePickerController()
    fileprivate let mediaPicker = MPMediaPickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageUrls: [URL] = []
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.videoPicker.delegate = self
        self.mediaPicker.delegate = self
    }

    @IBAction func showSongs(_ sender: Any) {
        self.present(self.mediaPicker, animated: true, completion: nil)
    }

    @IBAction func showPhotos(_ sender: UIButton) {
        
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func showVideos(_ sender: UIButton) {
        self.videoPicker.mediaTypes = [kUTTypeMovie, kUTTypeAVIMovie, kUTTypeVideo, kUTTypeMPEG4] as [String]
        self.present(self.videoPicker, animated: true, completion: nil)
    }
    
    fileprivate func fetchImages(for urls:[URL], images: @escaping ([UIImage]) -> () ) {

        let fetchResults = PHAsset.fetchAssets(withALAssetURLs: urls, options: nil)
        
        var tempImages: [UIImage] = []
        fetchResults.enumerateObjects(using: { photo, count, _ in
            PHImageManager.default().requestImage(for: photo, targetSize:  CGSize(width: 50.0, height: 50.0) , contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
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
        
        picker.dismiss(animated: true, completion: nil)
        
        self.fetchImages(for: self.imageUrls) {  [unowned self] images in
            self.images = images
            
            self.collectionView.reloadData()
            
            
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        cell.image.image = self.images[indexPath.row]
        return cell
    }
}

extension ViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        if let item = mediaItemCollection.items.first {
            
            //can retrieve media item with id later
            self.imageUrls.append(URL(string: String(item.persistentID))!)
            if let image = item.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) {
            self.images.append(image)
            self.collectionView.reloadData()
            }
        }
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
}


