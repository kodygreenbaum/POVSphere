//
//  MessageModeViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 4/25/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import ColorSlider
import CoreBluetooth

class MessageModeViewController: UIViewController, UITextFieldDelegate {
    
    private var _rotation : Int8 = 0
    
    let colorSlider = ColorSlider()
    var red: CGFloat = 1.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var selectedColorView: UIView!
    
    
    @IBAction func setColorOnePressed(sender: AnyObject) {
        
        let colorWrite : [UInt8] = [12, colorSlider.colorMapped]
        if let data: NSData? = NSData(bytes: colorWrite, length: 2 ){
            if(colorChar != nil) {
                periph.writeValue(data!, forCharacteristic: colorChar, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
    
    @IBAction func setColorTwoPressed(sender: AnyObject) {
        
        let colorWrite : [UInt8] = [13, colorSlider.colorMapped]
        if let data: NSData? = NSData(bytes: colorWrite, length: 2 ){
            if(colorChar != nil) {
                periph.writeValue(data!, forCharacteristic: colorChar, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
    
    @IBAction func setColorThreePressed(sender: AnyObject) {
        
        let colorWrite : [UInt8] = [14, colorSlider.colorMapped]
        if let data: NSData? = NSData(bytes: colorWrite, length: 2 ){
            if(colorChar != nil) {
                periph.writeValue(data!, forCharacteristic: colorChar, type: CBCharacteristicWriteType.WithResponse)
            }
        }
    }
    
    @IBAction func setColorFourPressed(sender: AnyObject) {
       
        let colorWrite : [UInt8] = [15, colorSlider.colorMapped]
        if let data: NSData? = NSData(bytes: colorWrite, length: 2 ){
            if(colorChar != nil) {
                periph.writeValue(data!, forCharacteristic: colorChar, type: CBCharacteristicWriteType.WithResponse)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageModeViewController.processBLE(_:)), name: "processBLE", object: nil)
        
        // Force Portrait
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdTextField.delegate = self
        fourthTextField.delegate = self
        
        //ColorSlider
        colorSlider.frame = CGRectMake(0, 0, 20, 150)
        sliderContainerView.addSubview(colorSlider)
        colorSlider.previewEnabled = true
        colorSlider.addTarget(self, action: #selector(MessageModeViewController.changedColor(_:)), forControlEvents: .ValueChanged)
        selectedColorView.backgroundColor = colorSlider.color
        self.selectedColorView.layer.borderWidth = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Rotate to Portrait
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= 20
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let data: NSData? = textField.text!.dataUsingEncoding(NSUTF8StringEncoding) {
            switch textField {
            case firstTextField:
                if(textOneChar != nil) {
                    periph.writeValue(data!, forCharacteristic: textOneChar, type: CBCharacteristicWriteType.WithResponse)
                }
                
                break
            case secondTextField:
                
                if(textTwoChar != nil) {
                    periph.writeValue(data!, forCharacteristic: textTwoChar, type: CBCharacteristicWriteType.WithResponse)
                }
                
                break
            case thirdTextField:
                
                if(textThreeChar != nil) {
                    periph.writeValue(data!, forCharacteristic: textThreeChar, type: CBCharacteristicWriteType.WithResponse)
                }
                
                break
            case fourthTextField:
                
                if(textFourChar != nil) {
                    periph.writeValue(data!, forCharacteristic: textFourChar, type: CBCharacteristicWriteType.WithResponse)
                }
                
                break
                
            default: break
            }
        }
    }
    
    // MARK: - Color Slider Functions
    func changedColor(slider: ColorSlider) {
        if let myCIColor = slider.color.coreImageColor {
            red = myCIColor.red
            green = myCIColor.green
            blue = myCIColor.blue
            selectedColorView.backgroundColor = slider.color
        }
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
