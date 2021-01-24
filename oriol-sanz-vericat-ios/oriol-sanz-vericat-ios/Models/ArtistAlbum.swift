//
//  ArtistAlbum.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class ArtistAlbum: Codable {
    
    var id: String
    var name: String
    var imageUrl: String
    var totalTracks: Int
    var releaseDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl
        case totalTracks
        case releaseDate
    }
    
    init() {
        id = ""
        name = ""
        imageUrl = ""
        totalTracks = 0
        releaseDate = Date()
    }
    
    init(id: String, name: String, imageUrl: String, totalTracks: Int, releaseDate: Date) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.totalTracks = totalTracks
        self.releaseDate = releaseDate
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        imageUrl = try values.decode(String.self, forKey: .imageUrl)
        totalTracks = try values.decode(Int.self, forKey: .totalTracks)
        releaseDate = try values.decode(Date.self, forKey: .releaseDate)
    }
}
