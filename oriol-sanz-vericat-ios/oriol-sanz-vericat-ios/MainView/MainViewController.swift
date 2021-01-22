//
//  MainViewController.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 18/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController {

    @IBOutlet weak var textfield_search_bar: UITextField!
    @IBOutlet weak var tableview_artists_list: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    var spotifyToken: String = ""
    
    let filesManager: FilesManager = FilesManager.init()
    
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
        
        artistsTableList.removeAll()
        tableview_artists_list.reloadData()
        
        textfield_search_bar.autocorrectionType = .no
        tableview_artists_list.delegate = self
        tableview_artists_list.dataSource = self
        
        searchButton.setTitle(NSLocalizedString("main_button_search", comment: "The search button title"), for: .normal)
    }
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            destination.modalPresentationStyle = .fullScreen
            if let index = tableview_artists_list.indexPathForSelectedRow?.row {
                destination.artist = artistsTableList[index]
                destination.spotifyToken = spotifyToken
            }
        }
    }
    
    // Search Button tap
    @IBAction func searchButtonTapped(_ sender: Any) {
        if let searchTerm = textfield_search_bar.text, searchTerm.count > 2 {
            
            self.showSpinner(onView: self.view)
            searchArtists(searchTerm: searchTerm)
        } else {
            
            presentError(description: NSLocalizedString("error_three_characters_required", comment: "Error description"))
        }
    }
    
    func loadData() {
        do {
            let data = try filesManager.read(fileNamed: "artistList.txt")
            let decoder = JSONDecoder()
            artistsTableList = try! decoder.decode([ArtistModel].self, from: data)
            tableview_artists_list.reloadData()
            self.removeSpinner()
        } catch {
            debugPrint("Error loading internal data")
        }
    }
}

// Extension to present error
extension MainViewController {
    
    func presentError(description: String) {
        let alert = UIAlertController(title: NSLocalizedString("error_title", comment: "Error title"),
                                          message: description,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("error_ok", comment: "Error ok button"),
                                          style: .default,
                                          handler: nil))

            self.present(alert, animated: true)
    }
}

// Extension for TableView Delegate & Data Source
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! ArtistTableViewCell
        
        let artist = artistsTableList[indexPath.row]
        cell.artistName.text = artist.name
        cell.artistImage.image = Utils.getImage(from: artist.imageUrl)
        
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
}

// Extension for Services
extension MainViewController {
    
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
                self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                self.removeSpinner()
            } else {
                if let data = data {
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.spotifyToken = jsonResponse["access_token"] as? String ?? ""
                        self.removeSpinner()
                    } else {
                        DispatchQueue.main.async {
                            self.removeSpinner()
                            self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                    }
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
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                }
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
                                    
                                    let encoder = JSONEncoder()
                                    encoder.outputFormatting = .prettyPrinted
                                    let data = try! encoder.encode(self.artistsTableList)
                                    do {
                                        try self.filesManager.save(fileNamed: "artistList.txt", data: data)
                                    } catch {
                                        
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.removeSpinner()
                                self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.removeSpinner()
                            self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                    }
                }
            }
        })
        dataTask.resume()
    }
}
