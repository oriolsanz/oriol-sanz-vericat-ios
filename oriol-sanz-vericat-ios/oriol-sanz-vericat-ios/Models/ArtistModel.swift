//
//  ArtistModel.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class ArtistModel {
    
    var name: String
    var imageUrl: String
    var musicGenre: String
    var followers: String
    var albums: [ArtistAlbum]
    
    public init() {
        name = ""
        imageUrl = ""
        musicGenre = ""
        followers = ""
        albums = []
    }
}
