//
//  ConnectViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth



class ConnectViewController: UIViewController {

    // CONSTANTS - struct containing global constants must be initialized
    let constants = Constants()
    
    // Vars
    var searching = false
    var connecting = false
    var blueToothOn = false
    
    // MARK: Outlets and Actions
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectButton: UIButton!
    @IBAction func connectButtonPressed(sender: AnyObject) {
        //self.performSegueWithIdentifier("modeselect", sender: self)
        if (blueToothOn) {
            if (!searching && !connecting) {
                searchForDevice()
            }
        } else {
            let alert =  UIAlertController(title: NSLocalizedString("Bluetooth Disabled", comment: "Bluetooth Disabled"), message:NSLocalizedString("Turn on bluetooth and try again!", comment: "Bluetooth must be enabled to locate the Sphere.") , preferredStyle: .Alert)
            
            let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force Portrait
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        bleManager = BLEManager()
        bleManager.bleHandler.centralManagerDidUpdateState(bleManager.centralManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "processBLE:", name: "processBLE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "blueToothStatusChanged:", name: "blueToothStatusChanged", object: nil)
        loadingIndicator.alpha = 0.0
        
    }
    
    // MARK: Helper Methods
    func searchForDevice() {
        searching = true
        deviceFound = false;
        bleManager.bleHandler.centralManagerDidUpdateState(bleManager.centralManager)
        
        // Start scanning for peripheral, if one is found, notification will
        // trigger "processBLE" with response 0
        bleManager.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        
       
        UIView.animateWithDuration(NSTimeInterval(0.6), animations: {
            self.loadingIndicator.alpha = 1.0
            self.connectButton.alpha = 0.0
        })
        self.loadingIndicator.startAnimating()
        
        // Time out scan if device not found after 4 seconds, display error message
        delay(4.0) {
            if(!deviceFound) {
                self.loadingIndicator.alpha = 0.0
                self.loadingIndicator.stopAnimating()
                UIView.animateWithDuration(NSTimeInterval(0.6), animations: {
                    self.connectButton.alpha = 1.0
                })
                self.searching = false
                bleManager.centralManager.stopScan()
                let alert =  UIAlertController(title: NSLocalizedString("No Device Found", comment: "No Device Found"), message:NSLocalizedString("Check that your Device is turned on and nearby, and that you have entered its ID # correctly. Then try again!", comment: "Device must be found before connecting.") , preferredStyle: .Alert)
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
                alert.addAction(okAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func connectToDevice () {
        self.connecting = true
        if periph != nil {
            bleManager.centralManager.cancelPeripheralConnection(periph!)
            bleManager.centralManager.connectPeripheral(periph!, options: nil)
        }
        else {
            let alert =  UIAlertController(title: NSLocalizedString("No Device Found", comment: "No Device Found"), message:NSLocalizedString("Device must be found before connecting.", comment: "Device must be found before connecting.") , preferredStyle: .Alert)
            
            let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func blueToothStatusChanged(notice:NSNotification) {
        if let userDict = notice.userInfo{
            self.blueToothOn = userDict["blueToothOn"] as! Bool
        }
    }
    
    func processBLE(notice:NSNotification) {
        if let userDict = notice.userInfo{
            let value = userDict["status"] as! Int
            let resp = value
            
            switch resp{
                
            case 0:
                if (self.searching) {
                    self.searching = false
                    deviceFound = true
                    connectToDevice()
                }
                break;
                
            case 1:
                self.connecting = false
                UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.loadingIndicator.alpha = 0.0
                    }, completion: nil)
                let alert =  UIAlertController(title: NSLocalizedString("Device Connected", comment: "Device Connected"), message:NSLocalizedString("Device was successfully connected.", comment: "Device was successfully connected.") , preferredStyle: .Alert)
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("modeselect", sender: self)
                })
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
                
            default:
                print("ConnectViewController processBLE Default Case Reached")
            }
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Stay in Portrait
    override func shouldAutorotate() -> Bool {
        return true
    }
    
}
