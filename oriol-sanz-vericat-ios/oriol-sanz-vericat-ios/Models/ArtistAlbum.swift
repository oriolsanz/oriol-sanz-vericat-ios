//
//  ArtistAlbum.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation

class ArtistAlbum {
    
    var id: String
    var name: String
    var imageUrl: String
    var totalTracks: Int
    var releaseDate: Date
    
    init() {
        id = ""
        name = ""
        imageUrl = ""
        totalTracks = 0
        releaseDate = Date()
    }
}
