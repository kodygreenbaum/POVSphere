//
//  MessageModeViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 4/25/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

class MessageModeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdTextField.delegate = self
        fourthTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= 24
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
