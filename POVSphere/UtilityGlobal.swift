//
//  UtilityGlobal.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import Foundation
import UIKit.UIColor
import CoreBluetooth


// MARK: Global Constants
let userDefaults = NSUserDefaults.standardUserDefaults()

struct Constants {
    // Keys used for accessing specific values from NSUserDefaults
}


// MARK: Global Vars
var bleManager: BLEManager!
var deviceName : String = "POV-Sphere"
var deviceFound: Bool! = false


//MARK: Global Helper Methods

/**
Wrapper method for GCD's dispatch_after method...
Lets us delay some code's execution in a clean way.

- parameter delay:   Double that specifies the time to wait before executing
*/
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension UIColor {
    var coreImageColor: CoreImage.CIColor? {
        return CoreImage.CIColor(color: self)  // The resulting Core Image color, or nil
    }
}