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
    public var token: String = ""
    
    // This function downloads an image
    public static func downloadImage(from url: String) -> Data? {
        
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
}

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
