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

class ArtModeViewController: UIViewController {
    
    let colorSlider = ColorSlider()
    var lastPoint = CGPoint.zero
    var hue: CGFloat = 1.0
    var red: CGFloat = 1.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 8.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
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
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var selectedColorview: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArtModeViewController.processBLE(_:)), name: "processBLE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArtModeViewController.globeWriteOccurred(_:)), name: "globeWriteOccurred", object: nil)
        
        // Force Landscape
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        colorSlider.frame = CGRectMake(0, 0, 20, 150)
        sliderContainerView.addSubview(colorSlider)
        colorSlider.previewEnabled = true
        colorSlider.addTarget(self, action: #selector(ArtModeViewController.changedColor(_:)), forControlEvents: .ValueChanged)
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
        
       // For Drawing
       if let touch = touches.first {
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
        
        curX = UInt8(Int(floor(fromPoint.x / xratio)))
        curY = UInt8(Int(floor(fromPoint.y / yratio)))
    
        if ((curX != lastX) || (curY != lastY)) {
            // Write To Buffer
            synced(self, closure: {
                self.buffer[self.buffEnd] = [self.curX, self.curY, self.colorSlider.colorMapped]
                if (self.buffEnd == 9899) {
                    self.buffEnd = 0
                } else {
                    self.buffEnd += 1
                }
            })
            
            if(!writing) {
                synced(self, closure: {
                    self.writing = true
                })
                //Kick off the buffer writing function
                var userDict = [String : Bool]()
                userDict["error"] = true
                NSNotificationCenter.defaultCenter().postNotificationName("globeWriteOccurred", object: self, userInfo: userDict)
            }
        }
        lastX = curX
        lastY = curY
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
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
            for (var b = 0; b < height; b += 1) {
                for (var a = 0; a < width; a += 1) {
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
                        for (var jj = 0; jj < xRatio; jj += 1) {
                            for (var ii = 0; ii < yRatio; ii += 1) {
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
                        globeXIndex += 1
                    }
                }
                globeXIndex = 0
                globeYIndex += 1
            }
                
       //     }, completion: { })
        free(pixels)
        
        return globeArray
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
                
                if let data: NSData? = NSData(bytes: buffer[buffStart], length: 3) {
                    if(writeChar != nil) {
                        periph.writeValue(data!, forCharacteristic: writeChar, type: CBCharacteristicWriteType.WithResponse)
                    }
                }
                
                print("Great Fail!")
            } else {
                synced(self, closure: {
                    // Do other buffer stuff
                    if (self.buffStart == 9899) {
                        self.buffStart = 0
                    } else {
                        self.buffStart += 1
                    }
                })
                if(buffStart != buffEnd) {
                    if let data: NSData? = NSData(bytes: buffer[buffStart], length: 3) {
                        if(writeChar != nil) {
                            periph.writeValue(data!, forCharacteristic: writeChar, type: CBCharacteristicWriteType.WithResponse)
                        }
                    }
                    print("Great Success!")
                } else {
                    synced(self, closure: {
                        self.writing = false
                    })
                }
            }
        }
    }

}
