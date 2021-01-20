//
//  DetailViewController.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistProfileImageView: UIImageView!
    @IBOutlet weak var artistGenresLabel: UILabel!
    @IBOutlet weak var artistFollowersLabel: UILabel!
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    var artist: ArtistModel?
    var spotifyToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureComponents()
        setupArtistDetails()
        getArtistAlbums(artistID: artist?.id ?? "")
    }
    
    func configureComponents() {
        
        albumsCollectionView.delegate = self
        albumsCollectionView.dataSource = self
        artist?.albums.removeAll()
        albumsCollectionView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        artist?.albums.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
        let album = artist?.albums[indexPath.row]
        cell.albumTitle.text = album?.name
        
        if let data = Utils.downloadImage(from: album?.imageUrl ?? ""), let image = UIImage(data: data) {
            
            // Thumbnail with image
            let thumbnail = image
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 160] as CFDictionary
            
            if let imageData = thumbnail.pngData(),
                let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
                let finalImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) {
                
                cell.albumImage.image = UIImage(cgImage: finalImage)
            } else {
                
                cell.albumImage.image = image
            }
            
        } else {
            
            cell.albumImage.image = UIImage(named: "profile_empty")
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    // Method to download the Albums
    func getArtistAlbums(artistID: String) {
        
        showSpinner(onView: self.view)
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/artists/\(artistID)/albums")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        if let token = spotifyToken {
            let headers = [
                "content-type":"application/json",
                "authorization": "Bearer \(token)"
            ]
            request.allHTTPHeaderFields = headers
        }
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                // TODO Error control
                self.removeSpinner()
            } else {
                if let data = data {
                    
                    // TODO paginación key "next"
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        // Here we navigate through JSON to locate the fields we want to use
                        
                        if let albums = jsonResponse["items"] {
                            for album in (albums as! NSArray as! [Any]) {
                                
                                var model = ArtistAlbum.init()
                                
                                if let id = (album as? [String: Any])?["id"] as? String {
                                    model.id = id
                                }
                                
                                if let name = (album as? [String: Any])?["name"] as? String {
                                    model.name = name
                                }
                                
                                if let images = (album as? [String: Any])?["images"] as? NSArray {
                                    if images.count > 0, let image = (images[0] as? [String: Any])?["url"] as? String {
                                            model.imageUrl = image
                                    }
                                }
                                
                                if let totalTracks = (album as? [String: Any])?["total_tracks"] as? Int {
                                    model.totalTracks = totalTracks
                                }
                                
                                if let releaseDate = (album as? [String: Any])?["release_date"] as? String {
                                    model.releaseDate = releaseDate
                                }
                                
                                self.artist?.albums.append(model)
                            }
                            DispatchQueue.main.async {
                                self.albumsCollectionView.reloadData()
                                self.removeSpinner()
                            }
                        }
                    } else {
                        // TODO ERROR Control
                        self.removeSpinner()
                    }
                } else {
                    // TODO ERROR Control
                    self.removeSpinner()
                }
            }
        })
        dataTask.resume()
    }
}
