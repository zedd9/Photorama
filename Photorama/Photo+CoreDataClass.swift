//
//  Photo+CoreDataClass.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/18.
//
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    var image: UIImage?
    
    public override func awakeFromInsert()
    {
        super.awakeFromInsert()
        
        title = ""
        photoID = ""
        remoteURL = URL(string: "")
        photoKey = NSUUID().uuidString
        dateTaken = Date()
    }
//    override func awakeFromInsert() {
//
//

//    }
}
