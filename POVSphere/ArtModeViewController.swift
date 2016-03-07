//
//  ArtModeViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class ArtModeViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var saveStaticButton: UIButton!
    @IBOutlet weak var newModeNameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
            let newMode : Mode = Mode(name: self.textField.text!)
            let pres : ModeSelectViewController = self.presentingViewController as! ModeSelectViewController
            pres.staticModes.append(newMode)
            self.saveButton.hidden = true
            self.cancelButton.hidden = true
            self.textField.text = ""
            self.textField.hidden = true
            self.newModeNameLabel.hidden = true
            saveStaticButton.hidden = false
            
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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
