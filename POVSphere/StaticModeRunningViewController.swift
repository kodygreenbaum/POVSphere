//
//  StaticModeRunningViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

class StaticModeRunningViewController: UIViewController {

    var mode : Mode!
    private var _index : Int = 0
    private var _rotation : Int8 = 0
    private var isAnalog = true
    
    var index : Int {
        get {return _index}
        set(newValue) { _index = newValue }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clockSelectButton: UIButton!
    
    @IBAction func finishButtonPressed(sender: AnyObject) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func clockSelectButtonPressed(sender: AnyObject) {
        if(isAnalog) {
            isAnalog = false
            clockSelectButton.setImage(UIImage(named: "DigitalClock"), forState: UIControlState.Normal)
            var mode = UInt8(11)
            if let data: NSData? = NSData(bytes: &mode, length: 1) {
                if(modeChar != nil) {
                    periph.writeValue(data!, forCharacteristic: modeChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        } else {
            isAnalog = true
            clockSelectButton.setImage(UIImage(named: "Clock"), forState: UIControlState.Normal)
            var mode = UInt8(5)
            if let data: NSData? = NSData(bytes: &mode, length: 1) {
                if(modeChar != nil) {
                    periph.writeValue(data!, forCharacteristic: modeChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        }
        
        
    }
    
    @IBAction func swipeRight(sender: AnyObject) {
        if(_rotation >= -5) {
            _rotation = _rotation - 1
            if let data: NSData? = NSData(bytes: &_rotation, length: 1) {
                if(speedChar != nil) {
                    periph.writeValue(data!, forCharacteristic: speedChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        }
    }
    
    @IBAction func swipeLeft(sender: AnyObject) {
        if(_rotation <= 5) {
            _rotation = _rotation + 1
            if let data: NSData? = NSData(bytes: &_rotation, length: 1) {
                if(speedChar != nil) {
                    periph.writeValue(data!, forCharacteristic: speedChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = self.mode
        .name
        
        if(self.mode.name != "Clock"){
            clockSelectButton.hidden = true
        } else {
            clockSelectButton.hidden = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StaticModeRunningViewController.processBLE(_:)), name: "processBLE", object: nil)
    }
    

    func processBLE(notice:NSNotification) {
        if let userDict = notice.userInfo{
            let resp = userDict["status"] as! Int
            if (resp == 2) {
                let alert = UIAlertController(title: NSLocalizedString("Device Disconnected", comment: "Device Disconnected"), message:NSLocalizedString("Device connection was lost.", comment: "Device connection was lost.") , preferredStyle: .Alert)
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    let welcomeVC = self.storyboard!.instantiateViewControllerWithIdentifier("normal")
                    UIApplication.sharedApplication().keyWindow?.rootViewController = welcomeVC
                })
                
                alert.addAction(okAction)
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
