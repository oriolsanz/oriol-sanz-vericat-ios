//
//  ArtistModel.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class ArtistModel {
    
    var id: String
    var name: String
    var imageUrl: String
    var musicGenre: String
    var followers: Int
    var albums: [ArtistAlbum]
    
    public init() {
        id = ""
        name = ""
        imageUrl = ""
        musicGenre = ""
        followers = 0
        albums = []
    }
}
