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
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    @IBOutlet weak var filterByDateButton: UIButton!
    @IBOutlet weak var filterFromLabel: UILabel!
    @IBOutlet weak var filterToLabel: UILabel!
    @IBOutlet weak var filterByTextTextField: UITextField!
    
    var artist: ArtistModel?
    var shownAlbums: [ArtistAlbum] = []
    var spotifyToken: String?
    
    let fromCheck: Int = 0
    let toCheck: Int = 1
    var fromDate: Date?
    var toDate: Date?
    
    var artistsList: [ArtistModel] = []
    
    var searchTerm: String = ""
    
    var scale = CGFloat(1.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureComponents()
        configurePinchInOut()
        setupArtistDetails()
        getArtistAlbums(artistID: artist?.id ?? "")
    }
    
    // Function for configure components
    func configureComponents() {
        
        albumsCollectionView.delegate = self
        albumsCollectionView.dataSource = self
        albumsCollectionView.dragInteractionEnabled = true
        shownAlbums = []
        artist?.albums.removeAll()
        albumsCollectionView.reloadData()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        albumsCollectionView.addGestureRecognizer(gesture)
        
        let fromGesture = UITapGestureRecognizer(target: self, action: #selector(handleFromPressGesture(_:)))
        filterFromLabel.isUserInteractionEnabled = true
        filterFromLabel.addGestureRecognizer(fromGesture)
        
        let toGesture = UITapGestureRecognizer(target: self, action: #selector(handleToPressGesture(_:)))
        filterToLabel.isUserInteractionEnabled = true
        filterToLabel.addGestureRecognizer(toGesture)
        
        filterByDateButton.titleLabel?.text = NSLocalizedString("detail_filter_by_date", comment: "Filter title")
        filterFromLabel.text = NSLocalizedString("detail_filter_by_date_from", comment: "Filter from")
        filterToLabel.text = NSLocalizedString("detail_filter_by_date_to", comment: "Filter to")
        
        filterByTextTextField.delegate = self
        filterByTextTextField.autocorrectionType = .no
        filterByTextTextField.placeholder = NSLocalizedString("detail_filter_by_title", comment: "Filter album by title")
    }
    
    // Function to configure pinch in / out
    func configurePinchInOut() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        view.addGestureRecognizer(pinch)
    }
    
    // Function to configure the model
    func setupArtistDetails() {
        
        artistNameLabel.text = artist?.name
        artistGenresLabel.text = artist?.musicGenre
        artistFollowersLabel.text = String(format: NSLocalizedString("detail_followers", comment: "Shows the followers count"), Utils.formatInt(int: artist?.followers ?? 0) ?? 0)
        artistProfileImageView.image = Utils.getImage(from: artist?.imageUrl ?? "")
        
    }
    
    // Back button pressed action
    @IBAction func backButtonTapped(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
    }
}

// Extension to present error
extension DetailViewController {
    
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

// Extension to pinch gesture handler
extension DetailViewController {
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        
        guard sender.view != nil else {
            return
        }
        
        if sender.state == .began || sender.state == .changed {
            
            if sender.scale > 1 {   // Zoom in
                
                if scale < 3.1 {
                    
                    scale = scale + 1
                }
            } else {                // Zoom out
                
                if scale > 0.1 {
                
                    scale = scale - 1
                }
            }
            
            albumsCollectionView.reloadData()
        }
    }
}

// Extension for picker and filter
extension DetailViewController {
    
    // PressGesture for From date label
    @objc func handleFromPressGesture(_ gesture: UITapGestureRecognizer) {
        
        presentDatePicker(title: NSLocalizedString("detail_filter_by_date_from", comment: "Filter from"), label: filterFromLabel, check: fromCheck)
    }
    
    // PressGesture for To date label
    @objc func handleToPressGesture(_ gesture: UITapGestureRecognizer) {
        
        presentDatePicker(title: NSLocalizedString("detail_filter_by_date_to", comment: "Filter to"), label: filterToLabel, check: toCheck)
    }
    
    // Filter Button pressed
    @IBAction func filterByDatePressed(_ sender: Any) {
        
        guard let fromDate = fromDate, let toDate = toDate else {
            self.presentError(description: NSLocalizedString("error_dates_needed", comment: "Error description"))
            return
        }
        
        if fromDate > toDate {
            self.presentError(description: NSLocalizedString("error_back_to_the_future", comment: "Error description"))
            return
        }
        
        var tempAlbums: [ArtistAlbum] = []
        if let albums = artist?.albums {
            for album in albums {
                
                let albumDate = album.releaseDate
                if fromDate < albumDate && toDate > albumDate {
                    
                    tempAlbums.append(album)
                }
            }
            shownAlbums.removeAll()
            
            for album in tempAlbums {
                
                shownAlbums.append(album)
            }
            albumsCollectionView.reloadData()
        } else {
            self.presentError(description: NSLocalizedString("error_no_albums", comment: "Error description"))
        }
    }
    
    // Show Date Picker
    func presentDatePicker(title: String, label: UILabel, check: Int) {
        
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        myDatePicker.datePickerMode = .date
        myDatePicker.maximumDate = Date()
        let alertController = UIAlertController(title: "\(title)\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        alertController.view.addSubview(myDatePicker)
        let selectAction = UIAlertAction(title: NSLocalizedString("picker_view_accept", comment: "Accept"), style: .default, handler: { _ in
            label.text = Utils.getStringDate(date: myDatePicker.date)
            if check == self.fromCheck {
                self.fromDate = myDatePicker.date
            } else if check == self.toCheck {
                self.toDate = myDatePicker.date
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("picker_view_cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// Extension for Drag & Drop
extension DetailViewController {
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        guard let collectionView = albumsCollectionView else {
            return
        }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = shownAlbums.remove(at: sourceIndexPath.row)
        shownAlbums.insert(item, at: destinationIndexPath.row)
    }
}

// Extension for CollectionView Delegate & Date Source
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shownAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
        let album = shownAlbums[indexPath.row]
        cell.albumTitle.text = album.name
        
        let size = cell.albumImage.bounds.size
        if let url = URL(string: album.imageUrl) {
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(thumbnailOfURL: url, size: size, scale: self.scale)!
                DispatchQueue.main.async { [weak self] in
                    cell.albumImage.image = image
                }
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
}

// Extension for save albums on disk
extension DetailViewController {
    
    // Func to save the albums
    func saveAlbums() {
        
        var index = 0
        for artist in artistsList {
            if artist.id == self.artist?.id {
                artistsList[index] = artist
            }
            index += 1
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(artistsList)
        do {
            try Utils.filesManager.save(fileNamed: Utils.savedDataFileName, data: data)
        } catch {
            debugPrint("Error saving albums")
        }
        self.removeSpinner()
    }
    
    // Func to load saved Albums
    func loadSavedAlbums() {
        
        for artistModel in artistsList {
            if artistModel.id == artist?.id {
                for album in artistModel.albums {
                    
                    shownAlbums.append(album)
                }
                self.albumsCollectionView.reloadData()
                self.removeSpinner()
                break
            }
        }
    }
}

extension DetailViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        filterByText(char: string)
        return true
    }
    
    func filterByText(char: String) {
        
        if char == "" {
            
            searchTerm.removeLast()
        } else {
            
            searchTerm.append(char)
        }
        
        if (searchTerm.count > 2) {
            
            var tempAlbums: [ArtistAlbum] = []
            if let albums = artist?.albums {
                for album in albums {
                    
                    let albumName = album.name.lowercased()
                    if albumName.contains(searchTerm) {
                        
                        tempAlbums.append(album)
                    }
                }
                shownAlbums.removeAll()
                
                for album in tempAlbums {
                    
                    shownAlbums.append(album)
                }
                albumsCollectionView.reloadData()
            }
        } else if searchTerm.count == 2 {
            // If there are less than 3 characters we reload all the albums
            shownAlbums.removeAll()
            var tempAlbums: [ArtistAlbum] = []
            if let albums = artist?.albums {
                for album in albums {
                        
                    tempAlbums.append(album)
                }
                shownAlbums.removeAll()
                
                for album in tempAlbums {
                    
                    shownAlbums.append(album)
                }
                albumsCollectionView.reloadData()
            }
        }
    }
}

extension DetailViewController {
    
    // Method to download the Albums
    func getArtistAlbums(artistID: String, keyOffset: String = "", isRecall: Bool = false) {
        
        if !isRecall {
            
            showSpinner(onView: self.view)
        }
        
        var offsetParam = ""
        
        if keyOffset != "" {
            
            offsetParam = "&offset=\(keyOffset)"
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.spotify.com/v1/artists/\(artistID)/albums?market=ES\(offsetParam)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
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
                DispatchQueue.main.async {
                    self.presentError(description: NSLocalizedString("error_default_text", comment: "Error description"))
                    self.loadSavedAlbums()
                }
            } else {
                if let data = data {
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        // Here we navigate through JSON to locate the fields we want to use
                        
                        if let albums = jsonResponse["items"] {
                            for album in (albums as! NSArray as! [Any]) {
                                
                                let model = ArtistAlbum.init()
                                
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
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let date = dateFormatter.date(from: releaseDate)
                                    model.releaseDate = date ?? Date()
                                }
                                
                                self.artist?.albums.append(model)
                                self.shownAlbums.append(model)
                            }
                            
                            // If has next, recall | max to 100
                            if let next = jsonResponse["next"] as? String {
                                
                                if let offset = Utils.getQueryStringParameter(url: next, param: "offset") {
                                
                                    if let intOffset = Int(offset), intOffset < 100 {
                                        
                                        self.getArtistAlbums(artistID: artistID, keyOffset: offset, isRecall: true)
                                    } else {
                                        
                                        DispatchQueue.main.async {
                                            self.albumsCollectionView.reloadData()
                                            self.saveAlbums()
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.albumsCollectionView.reloadData()
                                    self.saveAlbums()
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
            }
            self.removeSpinner()
        })
        dataTask.resume()
    }
}
