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
    
    var artist: ArtistModel?
    var shownAlbums: [ArtistAlbum] = []
    var spotifyToken: String?
    
    let fromCheck: Int = 0
    let toCheck: Int = 1
    var fromDate: Date?
    var toDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureComponents()
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
            // TODO Error
            print("Dates null")
            return
        }
        
        if fromDate > toDate {
            // TODO Error
            print("from > to")
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
            // TODO Error
            print("No hay albumes")
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
        cell.albumImage.image = Utils.getImage(from: album.imageUrl)
        
        cell.layoutIfNeeded()
        return cell
    }
}

extension DetailViewController {
    
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
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let date = dateFormatter.date(from: releaseDate)
                                    model.releaseDate = date ?? Date()
                                }
                                
                                self.artist?.albums.append(model)
                                self.shownAlbums.append(model)
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
