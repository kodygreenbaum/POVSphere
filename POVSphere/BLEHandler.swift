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
var writeChar: CBCharacteristic!

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
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            //prints device name and service UUID to terminal
            print("P: \(peripheral.name) - Discovered services: \(service.UUID)")
            // if there is an error
            if error != nil {
                //do nothing
            } else {
                //if no error when finding services, cast to CBService and runs through a for loop
                for service in peripheral.services as [CBService]!{
                    //discovers the characteristics for each service found
                    peripheral.discoverCharacteristics(nil, forService: service)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        //if there is an error
        if error != nil {
            //do nothing
        } else {
            //if no error in finding characteristics, cast to CBCharacteristic and runs through a for loop
            for characteristic in service.characteristics as [CBCharacteristic]! {
                print(characteristic.UUID)
                //string of UUID of characteristics
                switch characteristic.UUID.UUIDString {
                    
                case "CBB1": // Change to actual characteristic UUID from firmware
                    //prints to terminal
                    print("Found characteristic CBB1") // Change to actual UUID
                    writeChar = characteristic
                    
                default:
                    print("Characteristic not found")
                    
                }//switch
            }//for
        }//else
    }

   /*
    * When we want to ensure writes went through. Perhaps we want to restart the
    * Byte array transmission if it fails?
    */
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if ((error) != nil) {
            
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSOperationQueue.mainQueue().addOperationWithBlock ({ () -> Void in
            let found: Int = 2
            let dict:[NSObject:AnyObject]? = ["status": found]
            NSNotificationCenter.defaultCenter().postNotificationName("processBLE", object: self, userInfo: dict)
        })
    }
    
    
    
}