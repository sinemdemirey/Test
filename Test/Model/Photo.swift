//
//  Photo.swift
//  Test
//
//  Created by Sinem Demirey on 4.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: [Photo]
}

struct Photo: Codable {
    let title: String
    let image_url: String
}
