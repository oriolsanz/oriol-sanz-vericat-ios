//
//  ArtistTableViewCell.swift
//  oriol-sanz-vericat-ios
//
//  Created by Oriol Sanz Vericat on 19/01/2021.
//  Copyright © 2021 Oriol Sanz Vericat. All rights reserved.
//

import Foundation
import UIKit

class ArtistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var imgWrapper: UIView!
    
    override func awakeFromNib() {
        self.imgWrapper.clipsToBounds = true
    }
}
