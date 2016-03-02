//
//  BLEManager.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEManager: NSObject {
    var centralManager: CBCentralManager!
    var bleHandler: BLEHandler!
    
    override init () {
        bleHandler = BLEHandler()
        centralManager = CBCentralManager(delegate: bleHandler, queue: nil)
    }
}