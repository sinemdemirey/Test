//
//  APIService.swift
//  Test
//
//  Created by Sinem Demirey on 4.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

private let baseURLString = "https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&per_page=20&format=json&nojsoncallback=1"
private let apiKey = "a6d819499131071f158fd740860a5a88"


// old api key = 47eb41bd59d6b19c51ab87197a5a47d7
 

protocol APIServiceProtocol {
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? )->() )
}

class APIService: APIServiceProtocol {
    
    // Simulate a long waiting for fetching
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            
           var photoURL = [Photo]()
            Alamofire.request(baseURLString).responseJSON { (response) in
                switch response.result {
                    case .success(let value):
                    let json = JSON(value)
                          //print(json)
                    
                    let photos = json["photos"].dictionaryValue
                    let photoList = photos["photo"]!.arrayValue
                    
                    for imageData in photoList {
                        let farm = imageData["farm"].int
                        let server = imageData["server"].string
                        let secret = imageData["secret"].string
                        let id = imageData["id"].string
                        let imageURL = "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!).jpg"
                        let photoData = Photo(image_url: imageURL)
                        photoURL.append(photoData)
                    }
                    complete(true,photoURL,nil)
                    case .failure(let error):
                    print(error)
                
                }
            }
        }
    }
    
    
}


//                    let secrets = json["photos"]["photo"].arrayValue.map{$0["secret"].stringValue}
//                    print(secrets)
//                    let servers = json["photos"]["photo"].arrayValue.map{$0["server"].stringValue}
//                    print(servers)
//                    let ids = json["photos"]["photo"].arrayValue.map{$0["id"].stringValue}
//                    print(ids)
//                    let farms = json["photos"]["photo"].arrayValue.map{$0["farm"].stringValue}
//                    print(farms)
//
//                    let photoSourceURL = "https://farm\(farms.first).staticflickr.com/\(servers.first)/\(ids.first)_\(secrets.first).jpg"
//                    photos.append(photoSourceURL)


//            sleep(3)
//            let path = Bundle.main.path(forResource: "content", ofType: "json")!
//            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            let photos = try! decoder.decode(Photos.self, from: data)
//            complete( true, photos.photos, nil )
