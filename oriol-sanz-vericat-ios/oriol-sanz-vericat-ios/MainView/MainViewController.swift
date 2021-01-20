//
//  MainViewController.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 18/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textfield_search_bar: UITextField!
    @IBOutlet weak var tableview_artists_list: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    var spotifyToken: String = ""
    
    // The list of all searched artists
    var artistsTableList: [ArtistModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSpinner(onView: self.view)
        spotifyConnect()
        
        configureComponentes()
    }
    
    // This function sets the main delegates and configure de main view components
    func configureComponentes() {
        
        textfield_search_bar.autocorrectionType = .no
        tableview_artists_list.delegate = self
        tableview_artists_list.dataSource = self
        
        searchButton.setTitle(NSLocalizedString("main_button_search", comment: "The search button title"), for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            if let index = tableview_artists_list.indexPathForSelectedRow?.row {
                destination.artist = artistsTableList[index]
                destination.spotifyToken = spotifyToken
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! ArtistTableViewCell
        
        let artist = artistsTableList[indexPath.row]
        cell.artistName.text = artist.name
        
        if let data = Utils.downloadImage(from: artist.imageUrl), let image = UIImage(data: data) {
            
            // Thumbnail with image
            let thumbnail = image
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 80] as CFDictionary
            
            if let imageData = thumbnail.pngData(),
                let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
                let finalImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) {
                
                cell.artistImage.image = UIImage(cgImage: finalImage)
            } else {
                
                cell.artistImage.image = image
            }
            
        } else {
            
            cell.artistImage.image = UIImage(named: "profile_empty")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistsTableList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "detailSegue", sender: self)
        tableview_artists_list.deselectRow(at: indexPath, animated: true)
    }
    
    // In this fuction we use the button to search
    @IBAction func searchButtonTapped(_ sender: Any) {
        if let searchTerm = textfield_search_bar.text, searchTerm.count > 2 {
            
            self.showSpinner(onView: self.view)
            searchArtists(searchTerm: searchTerm)
        } else {
            
            // TODO Error control at least 3 chars to search
        }
    }
    
    // This function connects to SpotifyAPI to get the Token we need to work
    func spotifyConnect() {
    
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        
        let postData = NSMutableData(data: "grant_type=client_credentials".data(using: String.Encoding.utf8)!)
        postData.append("&client_id=\(Utils.spotifyClientID)".data(using: String.Encoding.utf8)!)
        postData.append("&client_secret=\(Utils.spotifySecretID)".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string:"https://accounts.spotify.com/api/token")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                // TODO Error control
                self.removeSpinner()
                print(error)
            } else {
                if let data = data {
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.spotifyToken = jsonResponse["access_token"] as? String ?? ""
                        self.removeSpinner()
                    } else {
                        self.removeSpinner()
                        // TODO Error Control
                    }
                } else {
                    self.removeSpinner()
                    // TODO Error Control
                }
            }
        })
        dataTask.resume()
    }
    
    // This function search the artists by name
    func searchArtists(searchTerm: String) {
        
        artistsTableList.removeAll()
        
        let formattedString = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        let headers = [
            "content-type":"application/json",
            "authorization": "Bearer \(spotifyToken)"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/search?type=artist&q=\(formattedString)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
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
                        
                        if let items = jsonResponse["artists"] as? [String: Any] {
                            if let artists = items["items"] {
                                for artist in (artists as! NSArray as! [Any]) {
                                    
                                    var model = ArtistModel.init()
                                    
                                    if let id = (artist as? [String: Any])?["id"] as? String {
                                        model.id = id
                                    }
                                    
                                    if let name = (artist as? [String: Any])?["name"] as? String {
                                        model.name = name
                                    }
                                    
                                    if let images = (artist as? [String: Any])?["images"] as? NSArray {
                                        if images.count > 0, let image = (images[0] as? [String: Any])?["url"] as? String {
                                                model.imageUrl = image
                                        }
                                    }
                                    
                                    var firstGenre = true
                                    for genre in (artist as? [String: Any])?["genres"] as? NSArray ?? [] {
                                        if firstGenre {
                                            model.musicGenre = genre as? String ?? ""
                                            firstGenre = false
                                        } else {
                                            model.musicGenre.append(", \(genre)")
                                        }
                                    }
                                    
                                    if let followers = ((artist as? [String: Any])?["followers"] as? [String:Any])?["total"] {
                                        
                                        model.followers = followers as? Int ?? 0
                                    }
                                    
                                    self.artistsTableList.append(model)
                                }
                                DispatchQueue.main.async {
                                    self.removeSpinner()
                                    self.tableview_artists_list.reloadData()
                                }
                            }
                        } else {
                            // TODO ERROR control
                            self.removeSpinner()
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

