//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/13.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    func updateWith(image: UIImage?){
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateWith(image: nil)
    }
    
    override func prepareForReuse() {
        super.awakeFromNib()
        
        updateWith(image: nil)
    }
}
