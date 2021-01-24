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
    
    var connectionAvailable: Bool = true
    
    // The list of all searched artists
    var artistsTableList: [ArtistModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSpinner(onView: self.view)
        configureComponentes()
        
        spotifyConnect()
    }
    
    // This function sets the main delegates and configure de main view components
    func configureComponentes() {
        
        artistsTableList.removeAll()
        tableview_artists_list.reloadData()
        tableview_artists_list.isHidden = true
        
        textfield_search_bar.autocorrectionType = .no
        
        tableview_artists_list.delegate = self
        tableview_artists_list.dataSource = self
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        gesture.minimumPressDuration = 1.0      // 1 second press
        tableview_artists_list.addGestureRecognizer(gesture)
        
        searchButton.setTitle(NSLocalizedString("main_button_search", comment: "The search button title"), for: .normal)
    }
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            destination.modalPresentationStyle = .fullScreen
            if let index = tableview_artists_list.indexPathForSelectedRow?.row {
                destination.artist = artistsTableList[index]
                destination.spotifyToken = spotifyToken
                destination.artistsList = artistsTableList
            }
        }
    }
    
    // Search Button tap
    @IBAction func searchButtonTapped(_ sender: Any) {
        if connectionAvailable {
            if let searchTerm = textfield_search_bar.text, searchTerm.count > 2 {
                
                searchArtists(searchTerm: searchTerm)
            } else {
                
                presentError(description: NSLocalizedString("error_three_characters_required", comment: "Error description"))
            }
        } else {
            presentError(description: NSLocalizedString("error_search_without_connection_text", comment: "Error description"))
        }
    }
}

// Extension for save and load data
extension MainViewController {
    
    // Func to save data to disk
    func saveData() {

        self.tableview_artists_list.isHidden = false
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self.artistsTableList)
        do {
            try Utils.filesManager.save(fileNamed: Utils.savedDataFileName, data: data)
        } catch {
            debugPrint("Error saving data")
        }
    }
    
    // Func to load data from disk
    func loadArtistsData() {
        do {
            let data = try Utils.filesManager.read(fileNamed: Utils.savedDataFileName)
            let decoder = JSONDecoder()
            self.artistsTableList = try! decoder.decode([ArtistModel].self, from: data)
            self.tableview_artists_list.reloadData()
            self.tableview_artists_list.isHidden = false
        } catch {
            debugPrint("Error loading internal data")
        }
    }
}

// Extension to present error
extension MainViewController {
    
    func presentError(description: String, showRetryButton: Bool = false) {
        let alert = UIAlertController(title: NSLocalizedString("error_title", comment: "Error title"),
                                          message: description,
                                          preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("error_ok", comment: "Error ok button"),
                                      style: .default,
                                      handler: nil))
    
        if showRetryButton {
            alert.addAction(UIAlertAction(title: NSLocalizedString("error_retry", comment: "Error rety button"),
                                          style: .default,
                                          handler: { _ in
                                          
                                            self.spotifyConnect()
            }))
        }

        self.present(alert, animated: true)
    }
}

// Extension for TableView Delegate & Data Source
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! ArtistTableViewCell
        
        let artist = artistsTableList[indexPath.row]
        cell.artistName.text = artist.name
        
        if artist.imageUrl != "" {
            
            let size = cell.artistImage.bounds.size
            let scale = traitCollection.displayScale
            if let url = URL(string: artist.imageUrl) {
                DispatchQueue.global(qos: .userInitiated).async {
                    let image = UIImage(thumbnailOfURL: url, size: size, scale: scale)!
                    DispatchQueue.main.async { [weak self] in
                        cell.artistImage.image = image
                    }
                }
            }
        } else {
            
            cell.artistImage.image = Utils.getImage(from: artist.imageUrl)
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
    
    // Scroll for parallax effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offSetY = self.tableview_artists_list.contentOffset.y
        for cell in self.tableview_artists_list.visibleCells as! [ArtistTableViewCell] {
            
            let x = cell.artistImage.frame.origin.x
            let w = cell.artistImage.bounds.width
            let h = cell.artistImage.bounds.height
            let y = ((offSetY - cell.frame.origin.y) / h) * 5
            cell.artistImage.frame = CGRect.init(x: x, y: y, width: w, height: h)
        }
    }
    
    // Share on social media when long click
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        let touchPoint = gesture.location(in: self.tableview_artists_list)
        if let indexPath = tableview_artists_list.indexPathForRow(at: touchPoint) {
            
            let cell = tableview_artists_list.cellForRow(at: indexPath) as? ArtistTableViewCell
            let imageToShare = [cell?.artistImage]
            
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            
            self.present(activityViewController, animated: true, completion: nil)
        }
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
                DispatchQueue.main.async {
                    self.presentError(description: NSLocalizedString("error_load_local_text", comment: "Error description"), showRetryButton: true)
                    self.connectionAvailable = false
                    self.loadArtistsData()
                    self.removeSpinner()
                }
            } else {
                if let data = data {
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.spotifyToken = jsonResponse["access_token"] as? String ?? ""
                        self.connectionAvailable = true
                        self.removeSpinner()
                    } else {
                        DispatchQueue.main.async {
                            self.connectionAvailable = false
                            self.presentError(description: NSLocalizedString("error_load_local_text", comment: "Error description"), showRetryButton: true)
                            self.loadArtistsData()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.connectionAvailable = false
                        self.presentError(description: NSLocalizedString("error_load_local_text", comment: "Error description"), showRetryButton: true)
                        self.loadArtistsData()
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    // This function search the artists by name
    func searchArtists(searchTerm: String, keyOffset: String = "", isRecall: Bool = false) {
        
        if !isRecall {
            
            showSpinner(onView: self.view)
            
            artistsTableList.removeAll()
        }
        
        var offsetParam = ""
        
        if keyOffset != "" {
            
            offsetParam = "&offset=\(keyOffset)"
        }
        
        let formattedString = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        let headers = [
            "content-type":"application/json",
            "authorization": "Bearer \(spotifyToken)"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/search?type=artist&q=\(formattedString)\(offsetParam)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.presentError(description: NSLocalizedString("error_load_local_text", comment: "Error description"))
                    self.connectionAvailable = false
                    self.loadArtistsData()
                    self.removeSpinner()
                }
            } else {
                if let data = data {
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        // Here we navigate through JSON to locate the fields we want to use
                        
                        var nextParam: String = ""
                        if let items = jsonResponse["artists"] as? [String: Any] {
                            if let next = items["next"] as? String {
                            
                                nextParam = next
                            }
                            if let artists = items["items"] {
                                for artist in (artists as! NSArray as! [Any]) {
                                    
                                    let model = ArtistModel.init()
                                    
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
                                
                                // If has next, recall | max to 100
                                if nextParam != "" {
                                    
                                    if let offset = Utils.getQueryStringParameter(url: nextParam, param: "offset") {
                                        
                                        if let intOffset = Int(offset), intOffset < 100 {
                                            
                                            self.searchArtists(searchTerm: searchTerm, keyOffset: offset, isRecall: true)
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                self.saveData()
                                                self.tableview_artists_list.reloadData()
                                                self.removeSpinner()
                                            }
                                        }
                                    } else {
                                        
                                        DispatchQueue.main.async {
                                            self.saveData()
                                            self.tableview_artists_list.reloadData()
                                            self.removeSpinner()
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.saveData()
                                        self.tableview_artists_list.reloadData()
                                        self.removeSpinner()
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
