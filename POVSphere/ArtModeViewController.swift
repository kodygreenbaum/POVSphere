//
//  ArtModeViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import ColorSlider
import CoreBluetooth

class ArtModeViewController: UIViewController, UITextFieldDelegate {
    
    let colorSlider = ColorSlider()
    var lastPoint = CGPoint.zero
    var hue: CGFloat = 1.0
    var red: CGFloat = 1.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 8.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var textfieldEditing = false
    
    private let xpix : CGFloat = 150.0
    private let ypix : CGFloat = 66.0
    private var xratio : CGFloat = 0.0
    private var yratio : CGFloat = 0.0
    
    private var lastX : UInt8 = 0
    private var lastY : UInt8 = 0
    private var curX : UInt8 = 0
    private var curY : UInt8 = 0
    
    private var buffer = [[UInt8]](count: (9900), repeatedValue: [UInt8](count: 3, repeatedValue: 0))
    private var buffStart = 0
    private var buffEnd = 0
    private var writing = false
    
    
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var saveStaticButton: UIButton!
    @IBOutlet weak var newModeNameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var selectedColorview: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var charValueLabel: UILabel!
    
    @IBOutlet weak var saveStaticVerticalConstraint: NSLayoutConstraint!
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        var x = 1
        if let data: NSData? = NSData(bytes: &x, length: 1) {
            if(clearGlobeChar != nil) {
                periph.writeValue(data!, forCharacteristic: clearGlobeChar, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        self.mainImageView.image = nil
        self.tempImageView.image = nil
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func undoButtonPressed(sender: AnyObject) {
        tempImageView.image = nil
        undoButton.hidden = true
    }
    
    @IBAction func saveAsStaticModeButtonPressed(sender: AnyObject) {
        self.textField.text = ""
        self.textField.hidden = false
        self.newModeNameLabel.hidden = false
        self.saveButton.hidden = false
        self.cancelButton.hidden = false
        self.saveStaticButton.hidden = true
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        if(textField.text == "" || textField.text == " ") {
            // Present Alert View
            let alert =  UIAlertController(title: NSLocalizedString("No Name", comment: "No Name"), message:NSLocalizedString("Please name your new mode.", comment: "Not Saved") , preferredStyle: .Alert)
            let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.textField.becomeFirstResponder()
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let newMode : Mode = Mode(name: self.textField.text!.lowercaseString, modeByte: 7)
            let nav : UINavigationController = self.presentingViewController as! UINavigationController
            let tab : UITabBarController = nav.viewControllers[0] as! UITabBarController
            
            let pres : StaticModeSelectViewController = tab.viewControllers![0] as! StaticModeSelectViewController
            pres.staticModes.append(newMode)
            self.saveButton.hidden = true
            self.cancelButton.hidden = true
            self.textField.text = ""
            self.textField.hidden = true
            self.newModeNameLabel.hidden = true
            saveStaticButton.hidden = false
            textField.resignFirstResponder()
            self.saveStaticVerticalConstraint.constant = 20
            UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
                self.containerView.layoutIfNeeded()
            })
            
            // Present Alert View
            let alert =  UIAlertController(title: NSLocalizedString("Great Success!", comment: "Saved New Mode"), message:NSLocalizedString(newMode.name + " was saved.", comment: "Mode Saved") , preferredStyle: .Alert)
            
            let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.saveButton.hidden = true
        self.cancelButton.hidden = true
        self.textField.text = ""
        self.textField.hidden = true
        self.newModeNameLabel.hidden = true
        saveStaticButton.hidden = false
        textField.resignFirstResponder()
        self.saveStaticVerticalConstraint.constant = 20
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })

    }
    
  
    @IBAction func nabDatDataPressed(sender: AnyObject) {
        var globeArray = [[UInt32]](count: Int(xpix), repeatedValue: [UInt32](count: Int(ypix), repeatedValue: 0))
        globeArray = mapPixelsToGlobe(Int(xpix), yPixels: Int(ypix))
        // Send Array as bitmap over bluetooth
    }
    
    @IBAction func sendColorButtonPressed(sender: AnyObject) {
        var color: UInt32 = 0
        color = hexValue(colorSlider.color)
        
        if let data: NSData? = NSData(bytes: &color, length: 4) {
            periph.writeValue(data!, forCharacteristic: writeChar, type: CBCharacteristicWriteType.WithResponse)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "processBLE:", name: "processBLE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "globeWriteOccurred:", name: "globeWriteOccurred", object: nil)
        
        // Force Landscape
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        colorSlider.frame = CGRectMake(0, 0, 20, 150)
        sliderContainerView.addSubview(colorSlider)
        colorSlider.previewEnabled = true
        colorSlider.addTarget(self, action: "changedColor:", forControlEvents: .ValueChanged)
        selectedColorview.backgroundColor = colorSlider.color
        self.selectedColorview.layer.borderWidth = 1
        //self.selectedColorview.layer.borderColor = UIColor.blackColor().CGColor
        
        if(view.frame.size.width > view.frame.size.height) {
            self.xratio = view.frame.size.width / xpix
            self.yratio = view.frame.size.height / ypix
        } else {
            self.xratio = view.frame.size.height / xpix
            self.yratio = view.frame.size.width / ypix
        }
        
    }

    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.saveStaticVerticalConstraint.constant = 20
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })
        textfieldEditing = false
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.saveStaticVerticalConstraint.constant = 212
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })
        textfieldEditing = true
    }

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    // Rotate to Landscape
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    // MARK: - Color Slider Functions
    func changedColor(slider: ColorSlider) {
        if let myCIColor = slider.color.coreImageColor {
            red = myCIColor.red
            green = myCIColor.green
            blue = myCIColor.blue
            redLabel.text = String(red)
            greenLabel.text = String(green)
            blueLabel.text = String(blue)
            selectedColorview.backgroundColor = slider.color
            
            //For Finding Actual Colors In For Slider
//            print()
//            print("Mapped Int: " + String(colorSlider.colorMapped))
//            print("red: " + String(red * 255))
//            print("green: " + String(green * 255))
//            print("blue: " + String(blue * 255))
//            print()
            
        }
        
        // var color = slider.color
    }
    
    // MARK: Methods For Drawing
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // For dismissing keyboard
        if(textfieldEditing) {
            self.view.endEditing(true)
            self.saveStaticVerticalConstraint.constant = 20
            UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
                self.containerView.layoutIfNeeded()
            })
            textfieldEditing = false
            if let touch = touches.first {
                lastPoint = touch.locationInView(self.view)
            }
            
        // For Drawing
        } else if let touch = touches.first {
            //Make tap falls within canvas
            let point = touch.locationInView(self.view)
            if(CGRectContainsPoint(self.mainImageView.bounds, point)) {
                lastPoint = touch.locationInView(self.view)
                // Merge tempImageView into mainImageView
                UIGraphicsBeginImageContext(mainImageView.frame.size)
                mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
                tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
                mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            
                tempImageView.image = nil
            
                swiped = false
            }
 
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
        undoButton.hidden = false
        
        curX = UInt8(Int(floor(fromPoint.x / xratio)))
        curY = UInt8(Int(floor(fromPoint.y / yratio)))
    
        if ((curX != lastX) && (curY != lastY)) {
            // Write To Buffer
            buffer[buffEnd] = [curX, curY, colorSlider.colorMapped]
            if (buffEnd == 9899) {
                buffEnd = 0
            } else {
                buffEnd += 1
            }
            if(!writing) {
                writing = true
                //Kick off the buffer writing function
            }
        }
        lastX = curX
        lastY = curY
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(!textfieldEditing) {
            if let touch = touches.first {
                let point = touch.locationInView(self.view)
                if(CGRectContainsPoint(self.mainImageView.bounds, point)) {
                    swiped = true
                    let currentPoint = touch.locationInView(view)
                    drawLineFrom(lastPoint, toPoint: currentPoint)
        
                    lastPoint = currentPoint
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped && !textfieldEditing {
            // Draw a Single Point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
    }
    
    func mapPixelsToGlobe(xPixels : Int, yPixels : Int) -> [[UInt32]] {
        
        
        let inputCGImage : CGImageRef = (mainImageView.image?.CGImage)!
        let width : Int = CGImageGetWidth(inputCGImage)
        let height : Int = CGImageGetHeight(inputCGImage);
        
        let bytesPerPixel = 4;
        let bytesPerRow = bytesPerPixel * width;
        let bitsPerComponent = 8;
        
        let pixels : UnsafeMutablePointer<Void> = calloc(height * width, sizeof(UInt32));
        
        
        let colorSpaceRef : CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!;
        let contextRef : CGContextRef = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpaceRef, CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)!;
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage);
        
        
        // Run processor intensive calculation on background thread
        var currentPixel : UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>(pixels)
        
        let xRatio = width/xPixels
        let yRatio = height/yPixels
        
        var globeArray = [[UInt32]](count: xPixels, repeatedValue: [UInt32](count: yPixels, repeatedValue: 0))
        var imagePixelArray = [[UInt32]](count: width, repeatedValue: [UInt32](count: height, repeatedValue: 0))
        
        // Populate 2-D Array of image's pixels
        //backgroundThread(0.0,
        //    background: {
            for (var b = 0; b < height; b++) {
                for (var a = 0; a < width; a++) {
                    let color : UInt32 = currentPixel.memory
                    imagePixelArray[a][b] = color
                    currentPixel++;
                }
            }
            // Now we have 2-d Array of image's pixels...
            var globeXIndex = 0
            var globeYIndex = 0
            // Loop over every xRatio by yRatio section of Image's Pixels
            // Find Most Occurring Pixel Color
            // Save it to globeArray
            for (var j = 0; j < height; j+=yRatio) {
                for (var i = 0; i < width; i+=xRatio) {
                    if(globeXIndex < xPixels && globeYIndex < yPixels) {
                        var s = [UInt32: Int]()
                        for (var jj = 0; jj < xRatio; jj++) {
                            for (var ii = 0; ii < yRatio; ii++) {
                                let clr : UInt32 = imagePixelArray[i + ii][j + jj]
                                if let val = s[clr] {
                                    s[clr] = val + 1
                                } else {
                                    s.updateValue(1, forKey: clr)
                                }
                            }
                        }
                        
                        let max = s.values.maxElement()
                        
                        for(color, count) in s {
                            if (count == max) {
                                globeArray[globeXIndex][globeYIndex] = color
                            }
                        }
                        globeXIndex++
                    }
                }
                globeXIndex = 0
                globeYIndex++
            }
                
       //     }, completion: { })
        free(pixels)
        
        return globeArray
    }
    
    // MARK: Helpers for Pixel Color Value Calculations
    
    func mask8(value : UInt32) -> UInt32 {
        return value & UInt32(0xFF)
    }
    
    func redValue(value : UInt32) -> UInt32 {
        return mask8(value)
    }
    
    func greenValue(value : UInt32) -> UInt32 {
        return mask8(value >> 8)
    }
    
    func blueValue(value : UInt32) -> UInt32 {
        return mask8(value >> 16)
    }
    
    func hexValue (color : UIColor) -> UInt32 {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            var colorAsUInt : UInt32 = 0
            colorAsUInt += UInt32(red * 255.0) << 16 + UInt32(green * 255.0) << 8 + UInt32(blue * 255.0)
            return colorAsUInt
        } else {
            return 0
        }
    }
    
    func processBLE(notice:NSNotification) {
        if let userDict = notice.userInfo{
            let resp = userDict["status"] as! Int
            if (resp == 2) {
                let alert = UIAlertController(title: NSLocalizedString("Device Disconnected", comment: "Device Disconnected"), message:NSLocalizedString("Device connection was lost.", comment: "Device connection was lost.") , preferredStyle: .Alert)
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    let welcomeVC = self.storyboard!.instantiateViewControllerWithIdentifier("normal")
                    UIApplication.sharedApplication().keyWindow?.rootViewController = welcomeVC
                })
                
                alert.addAction(okAction)
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func globeWriteOccurred(notice:NSNotification) {
        if let userDict = notice.userInfo{
            let resp = userDict["error"] as! Bool
            if (resp == true) {
                // Do buffer stuff
                
                if let data: NSData? = NSData(bytes: bytes, length: 3) {
                    if(writeChar != nil) {
                        periph.writeValue(data!, forCharacteristic: writeChar, type: CBCharacteristicWriteType.WithResponse)
                        
                        // For Printing Coordinate and Color Value
                        //                    print("x: ", terminator:"")
                        //                    print(curX)
                        //                    print("y: ", terminator:"")
                        //                    print(curY)
                        //                    print("color: ", terminator:"")
                        //                    print(colorSlider.colorMapped)
                    }
                }
                
                print("Great Fail!")
            } else {
                // Do other buffer stuff
                
                if let data: NSData? = NSData(bytes: bytes, length: 3) {
                    if(writeChar != nil) {
                        periph.writeValue(data!, forCharacteristic: writeChar, type: CBCharacteristicWriteType.WithResponse)
                        
                        // For Printing Coordinate and Color Value
                        //                    print("x: ", terminator:"")
                        //                    print(curX)
                        //                    print("y: ", terminator:"")
                        //                    print(curY)
                        //                    print("color: ", terminator:"")
                        //                    print(colorSlider.colorMapped)
                    }
                }
                print("Great Success!")
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
