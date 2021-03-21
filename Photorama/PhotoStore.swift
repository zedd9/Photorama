//
//  PhotoStore.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/07.
//

import Foundation
import UIKit
import CoreData

enum ImageResult {
    case Success(UIImage)
    case Failure(Error)
}

enum PhotoError: Error{
    case ImageCreationError
}

class PhotoStore {
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    let imageStore = ImageStore()
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchRecentPhotos(  completion: @escaping(PhotosResult) -> Void) {
        let url = FlickrAPI.rencentPhotosURL()
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let res = response as? HTTPURLResponse {
                print("statusCode: \(res.statusCode)")
                print("allHeaderFields: \(res.allHeaderFields)")
            }
            
            
            var result = self.processRecentPhotosRequest(data: data, error: error)
            if case let .Success(photos) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performAndWait {
                    try! mainQueueContext.obtainPermanentIDs(for: photos)
                }
                let objectIDs = photos.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                             
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            completion(result)
        }
        
        task.resume()
    }
    
    func fetchImageForPhoto(photo: Photo, completion: @escaping(ImageResult) -> Void){
        let photoKey = photo.photoKey!
        if let image = imageStore.imageForKey(key: photoKey) {
            photo.image = image
            completion(.Success(image))
            return
        }
        
        guard let photoURL = photo.remoteURL else { return }
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image: image, forKey: photoKey)
            }
            
            completion(result)
        }
        task.resume()
    }
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data,
              let image = UIImage(data: imageData)
        else {
            if data == nil {
                return .Failure(error!)
            } else {
                return .Failure(PhotoError.ImageCreationError)
            }
        }
        
        return .Success(image)
    }
    
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        return FlickrAPI.photosFromJSONData(data: jsonData, inContext: self.coreDataStack.mainQueueContext)
    }
    
    func fetchMainQueuePhotos(predicate: NSPredicate? = nil,
                              sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos = [Photo]()
        var fetchRequestError: Error?
        mainQueueContext.performAndWait {
            do {
                let items = try fetchRequest.execute()// mainQueueContext.execute(fetchRequest)
                for item in items {
                    mainQueuePhotos.append(item)
                }
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        if mainQueuePhotos.count == 0 {
            throw fetchRequestError!
        }
    
        return mainQueuePhotos
    }
}
