//
//  Phote.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/07.
//

import Foundation
import UIKit

class Photo : Equatable{
    
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    var image: UIImage?
    
    init(title: String, photoID: String, remoteURL: URL, dateTaken: Date) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
        self.image = nil
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoID == rhs.photoID
    }
    
}
