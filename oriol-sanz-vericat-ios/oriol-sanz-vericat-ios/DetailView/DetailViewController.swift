//
//  DetailViewController.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistProfileImageView: UIImageView!
    @IBOutlet weak var artistGenresLabel: UILabel!
    @IBOutlet weak var artistFollowersLabel: UILabel!
    
    var artist: ArtistModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupArtistDetails()
    }
    
    func setupArtistDetails() {
        
        artistNameLabel.text = artist?.name
        artistGenresLabel.text = artist?.musicGenre
        artistFollowersLabel.text = String(format: NSLocalizedString("detail_followers", comment: "Shows the followers count"), Utils.formatInt(int: artist?.followers ?? 0) ?? 0)
        
        if let imageUrl = artist?.imageUrl {
            if let data = Utils.downloadImage(from: imageUrl), let image = UIImage(data: data) {
                
                // Thumbnail with image
                let thumbnail = image
                let options = [
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: 80] as CFDictionary
                
                if let imageData = thumbnail.pngData(),
                    let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
                    let finalImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) {
                    
                    artistProfileImageView.image = UIImage(cgImage: finalImage)
                } else {
                    
                    artistProfileImageView.image = image
                }
                
            } else {
                
                artistProfileImageView.image = UIImage(named: "profile_empty")
            }
        } else {
            artistProfileImageView.image = UIImage(named: "profile_empty")
        }
    }
}
