//
//  PhotoStore.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/07.
//

import Foundation
import UIKit

enum ImageResult {
    case Success(UIImage)
    case Failure(Error)
}

enum PhotoError: Error{
    case ImageCreationError
}

class PhotoStore {
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
            
            
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
//            if let jsonData = data {
//                do {
//                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
//                    print(jsonObject)
//                }
//                catch let error {
//                    print("Error creating JSON object: \(error)")
//                }
//            }
//            else if let requestError = error {
//                print("Error fetching recent photos: \(requestError)")
//            } else {
//                print("Unexpected error with the request")
//            }
        }
        
        task.resume()
    }
    
    func fetchImageForPhoto(photo: Photo, completion: @escaping(ImageResult) -> Void){
        if let image = photo.image {
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
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
        return FlickrAPI.photosFromJSONData(data: jsonData)
    }
}
