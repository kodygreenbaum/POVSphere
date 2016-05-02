//
//  FireworksViewController.swift
//  POVSphere
//
//  Created by Daniel Lerner on 5/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

class FireworksViewController: UIViewController {
    
    private var _rotation : Int8 = 0
    private let xpix : CGFloat = 150.0
    private let ypix : CGFloat = 66.0
    private var xratio : CGFloat = 0.0
    private var yratio : CGFloat = 0.0
    var brushWidth: CGFloat = 12.0
    var opacity: CGFloat = 1.0
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        if(_rotation >= -5) {
            _rotation = _rotation - 1
            if let data: NSData? = NSData(bytes: &_rotation, length: 1) {
                if(speedChar != nil) {
                    periph.writeValue(data!, forCharacteristic: speedChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        }
    }
    
    @IBAction func leftButtonPressed(sender: AnyObject) {
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArtModeViewController.processBLE(_:)), name: "processBLE", object: nil)
        
        // Force Landscape
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        if(view.frame.size.width > view.frame.size.height) {
            self.xratio = view.frame.size.width / xpix
            self.yratio = view.frame.size.height / ypix
        } else {
            self.xratio = view.frame.size.height / xpix
            self.yratio = view.frame.size.width / ypix
        }
        
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    // Rotate to Landscape
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    // MARK: Methods For Drawing
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // For Drawing
        if let touch = touches.first {
            //Make tap falls within canvas
            let point = touch.locationInView(self.view)
            if(CGRectContainsPoint(self.mainImageView.bounds, point)) {
                drawLineFrom(touch.locationInView(self.view), toPoint: touch.locationInView(self.view), erase: false)
                
                let curX = UInt8(Int(floor(point.x / xratio)))
                let curY = UInt8(Int(floor(point.y / yratio)))
                
                
                // Construct array of points
                var currentWrite = [UInt8]()
                
                currentWrite.append(curX)
                currentWrite.append(curY)
                
                
                if let data: NSData? = NSData(bytes: currentWrite, length: 2) {
                    if(fireWorkWriteChar != nil) {
                        periph.writeValue(data!, forCharacteristic: fireWorkWriteChar, type: CBCharacteristicWriteType.WithResponse)
                    }
                }
                
                
                delay(1.0, closure: {self.drawLineFrom(point, toPoint: point, erase: true)})
                // Merge tempImageView into mainImageView
                UIGraphicsBeginImageContext(mainImageView.frame.size)
                mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
                tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
                mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                tempImageView.image = nil
                
            }
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, erase :Bool) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        if(erase) {
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
        } else {
            CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0)
        }
        
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
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
    
}
