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
var rpmChar: CBCharacteristic!
var modeChar: CBCharacteristic!
var speedChar: CBCharacteristic!
var textOneChar: CBCharacteristic!
var textTwoChar: CBCharacteristic!
var textThreeChar: CBCharacteristic!
var textFourChar: CBCharacteristic!
var clearGlobeChar: CBCharacteristic!


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
                    
                case "00000000-0000-1000-8000-00805F9B34F1":
                    writeChar = characteristic
                    print("Found Write Characteristic")
                case "00000000-0000-1000-8000-00805F9B34FB":
                    rpmChar = characteristic
                    print("Found RPM Characteristic")
                    peripheral.setNotifyValue(true, forCharacteristic: writeChar)
                case "00000000-0000-1000-8000-00805F9B34F2":
                    modeChar = characteristic
                    print("Found Mode Characteristic")
                case "00000000-0000-1000-8000-00805F9B34FC":
                    speedChar = characteristic
                    print("Found Speed Characteristic")
                case "00000000-0000-1000-8000-00805F9B34F4":
                    textOneChar = characteristic
                    print("Found TextOne Characteristic")
                case "00000000-0000-1000-8000-00805F9B34F5":
                    textTwoChar = characteristic
                    print("Found TextTwo Characteristic")
                case "00000000-0000-1000-8000-00805F9B34F6":
                    textThreeChar = characteristic
                    print("Found TextThree Characteristic")
                case "00000000-0000-1000-8000-00805F9B34F7":
                    textFourChar = characteristic
                    print("Found TextFour Characteristic")
                case "00000000-0000-1000-8000-00805F9B34F8":
                    clearGlobeChar = characteristic
                    print("Found ClearGlobe Characteristic")
                default:
                    print("Characteristic not found")
                    
                }//switch
            }//for
        }//else
    }

    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (characteristic == writeChar) {
            
            var userDict = [String : Bool]()
            
            userDict["error"] = (error != nil)
 
            NSNotificationCenter.defaultCenter().postNotificationName("globeWriteOccurred", object: self, userInfo: userDict)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSOperationQueue.mainQueue().addOperationWithBlock ({ () -> Void in
            let found: Int = 2
            let dict:[NSObject:AnyObject]? = ["status": found]
            NSNotificationCenter.defaultCenter().postNotificationName("processBLE", object: self, userInfo: dict)
        })
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        NSNotificationCenter.defaultCenter().postNotificationName("characteristicUpdated", object: self, userInfo: nil)
        
        print("\(rpmChar.value!)")
    }

    
    
}