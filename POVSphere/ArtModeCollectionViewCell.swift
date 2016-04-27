//
//  ArtModeCollectionViewCell.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 4/25/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class ArtModeCollectionViewCell: UICollectionViewCell {
    
    var color : UInt8 = 0
    
    @IBOutlet weak var button: UIButton!
    
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.backgroundColor = UIColor.blueColor()
    }
    
    @IBAction func buttonTouchedDown(sender: AnyObject) {
        self.backgroundColor = UIColor.blueColor()
    }
    
    @IBAction func buttonDraggedInto(sender: AnyObject) {
        self.backgroundColor = UIColor.blueColor()
    }
}
