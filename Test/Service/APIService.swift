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

private let baseURLString = "https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=a6d819499131071f158fd740860a5a88&per_page=20&format=json&nojsoncallback=1"
private let APIKey = "a6d819499131071f158fd740860a5a88"

private let photoSourceURL = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
// old api key = 47eb41bd59d6b19c51ab87197a5a47d7
 

protocol APIServiceProtocol {
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? )->() )
}

class APIService: APIServiceProtocol {
    
    // Simulate a long waiting for fetching
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            
            Alamofire.request(baseURLString).responseJSON { (response) in
                switch response.result {
                    case .success(let value):
                    let json = JSON(value)
                          print(json)
                    
                    let secrets = json["photos"]["photo"].arrayValue.map{$0["secret"].stringValue}
                    print(secrets)
                    let servers = json["photos"]["photo"].arrayValue.map{$0["server"].stringValue}
                    print(servers)
                    let ids = json["photos"]["photo"].arrayValue.map{$0["id"].stringValue}
                    print(ids)
                    let farms = json["photos"]["photo"].arrayValue.map{$0["farm"].stringValue}
                    print(farms)
                    
                    case .failure(let error):
                    print(error)
                }
                
            }
//            sleep(3)
//            let path = Bundle.main.path(forResource: "content", ofType: "json")!
//            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            let photos = try! decoder.decode(Photos.self, from: data)
//            complete( true, photos.photos, nil )
        }
    }
    
    
}
