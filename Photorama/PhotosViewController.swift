//
//  PhotosViewController.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/07.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchRecentPhotos() {
            (PhotosResult) -> Void in
               
            OperationQueue.main.addOperation {
                switch PhotosResult {
                case let .Success(photos):
                    print("Successfully found \(photos.count) recent photos.")
                    self.photoDataSource.photos = photos
                case let .Failure(error):
                    self.photoDataSource.photos.removeAll()
                    print("Error fetching recnet photos: \(error)")
                }
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        store.fetchImageForPhoto(photo: photo) { (result) in
            
            OperationQueue.main.addOperation {
                let photoIndex = self.photoDataSource.photos.firstIndex(of: photo)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWith(image: photo.image)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        }
    }
}
