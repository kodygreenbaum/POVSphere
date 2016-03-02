//
//  BLEHandler.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

var periph: CBPeripheral!
var service: CBService!

class BLEHandler: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    override init () {
        super.init()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch (central.state) {
        case .Unsupported: print("BLE is unsupported.")
        case .Unauthorized: print("BLE is unauthorized.")
        case .Unknown: print("BLE is unknown.")
        case .Resetting: print("BLE is resetting.")
        case .PoweredOff:
            print("BLE is powered off.")
            let dict:[NSObject:AnyObject]? = ["blueToothOn": false]
            NSNotificationCenter.defaultCenter().postNotificationName("blueToothStatusChanged", object: self, userInfo: dict)
        case .PoweredOn: print("BLE is powered on.")
            let dict:[NSObject:AnyObject]? = ["blueToothOn": true]
            NSNotificationCenter.defaultCenter().postNotificationName("blueToothStatusChanged", object: self, userInfo: dict)
            }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("\(peripheral.name) : \(RSSI) dBm")
        if (peripheral.name != nil) {
            if (peripheral.name == deviceName) { //"ECE315"
                periph = peripheral
                NSOperationQueue.mainQueue().addOperationWithBlock ({ () -> Void in
                    let found: Int = 0
                    let dict:[NSObject:AnyObject]? = ["status": found]
                    NSNotificationCenter.defaultCenter().postNotificationName("processBLE", object: self, userInfo: dict)
                })
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if peripheral.name != nil {
            print("\(peripheral.name) connected.")
            NSOperationQueue.mainQueue().addOperationWithBlock ({ () -> Void in
                let found: Int = 1
                let dict:[NSObject:AnyObject]? = ["status": found]
                NSNotificationCenter.defaultCenter().postNotificationName("processBLE", object: self, userInfo: dict)
            })
            print("UUID: \(peripheral.identifier.UUIDString)")
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
    
}