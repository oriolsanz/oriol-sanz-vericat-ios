//
//  Utils.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation
import UIKit

var vSpinner : UIView?

class Utils {
    static let spotifyClientID: String = "ba7dfd34f3304c58b58ac4b2f0fdc807"
    static let spotifySecretID: String = "1d33ec4876454d2e817313146fbae994"
    static let savedDataFileName: String = "artistList.txt"
    static let filesManager: FilesManager = FilesManager.init()
    
    // This function downloads an image
    static func downloadImage(from url: String) -> Data? {
        
        let tempURL = URL(string: url)
        
        if let varURL = tempURL {
            let data = (try? Data(contentsOf: varURL))
            return data
        }
        return nil
    }
    
    // This function formats an Int to a readable String (p.e. 2000 -> 2.000)
    public static func formatInt(int: Int) -> String?{
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: int))
        return formattedNumber
    }
    
    // This function formats a date to string
    public static func getStringDate(date: Date) -> String {
        
        let components = date.get(.day, .month, .year)
        let dateString = "\(components.day ?? 1)-\(components.month ?? 1)-\(components.year ?? 2020)"
        
        return dateString
    }
    
    // This function return an UIImage giving an url
    public static func getImage(from url: String) -> UIImage {
        if let data = downloadImage(from: url), let image = UIImage(data: data) {
            
            // Thumbnail with image
            let thumbnail = image
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 160] as CFDictionary
            
            if let imageData = thumbnail.pngData(),
                let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
                let finalImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) {
                
                return UIImage(cgImage: finalImage)
            } else {
                
                return image
            }
            
        } else {
            if let defaultImage = UIImage(named: "profile_empty") {
                return defaultImage
            } else {
                return UIImage()
            }
        }
    }
}

// Extension for spinner
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

// Date extension for get the day, month and year
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
