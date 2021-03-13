//
//  FlickrApi.swift
//  Photorama
//
//  Created by 신현욱 on 2021/03/07.
//

import Foundation


enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(Error)
}

enum FlickrError: Error {
    case InvalidJsonData
}

struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        var componets = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        componets.queryItems = queryItems
        
        return componets.url!
    }
    
    static func rencentPhotosURL() -> URL {
        return flickrURL(method: .RecentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    static func photosFromJSONData(data: Data) -> PhotosResult {
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [NSString:AnyObject],
                  let photos = jsonDictionary["photos"] as? [String:AnyObject],
                  let photosArray = photos["photo"] as? [[String:AnyObject]]  else {
                return .Failure(FlickrError.InvalidJsonData)
            }
                        
            var finalPhotos = [Photo]()
            for photoJson in photosArray {
                if let photo = photoFromJsonObject(json: photoJson) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                return .Failure(FlickrError.InvalidJsonData)
            }
            
            return .Success(finalPhotos)
        } catch let error {
            return .Failure(error)
        }
    }
    
    private static func photoFromJsonObject(json: [String : AnyObject]) -> Photo? {
        guard let photoId = json["id"] as? String,
              let title = json["title"] as? String,
              let dateString = json["datetaken"] as? String,
              let photoURLString = json["url_h"] as? String,
              let url = URL(string: photoURLString),
              let dateTaken = dateFormatter.date(from: dateString)
        else {
            return nil
        }
        
        return Photo(title: title, photoID: photoId, remoteURL: url, dateTaken: dateTaken)
    }
    
  
}
