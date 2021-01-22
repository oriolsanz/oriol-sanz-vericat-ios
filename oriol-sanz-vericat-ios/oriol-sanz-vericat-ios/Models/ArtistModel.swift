//
//  ArtistModel.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class ArtistModel: Codable {
    
    var id: String
    var name: String
    var imageUrl: String
    var musicGenre: String
    var followers: Int
    var albums: [ArtistAlbum]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl
        case musicGenre
        case followers
        case albums
    }
    
    public init() {
        id = ""
        name = ""
        imageUrl = ""
        musicGenre = ""
        followers = 0
        albums = []
    }
    
    init(id: String, name: String, imageUrl: String, musicGenre: String, followers: Int, albums: [ArtistAlbum]) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.musicGenre = musicGenre
        self.followers = followers
        self.albums = albums
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        imageUrl = try values.decode(String.self, forKey: .imageUrl)
        musicGenre = try values.decode(String.self, forKey: .musicGenre)
        followers = try values.decode(Int.self, forKey: .followers)
        albums = try values.decode([ArtistAlbum].self, forKey: .albums)
    }
}
