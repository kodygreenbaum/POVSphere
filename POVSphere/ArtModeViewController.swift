//
//  ArtModeViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import ColorSlider

class ArtModeViewController: UIViewController, UITextFieldDelegate {
    
    let colorSlider = ColorSlider()
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var saveStaticButton: UIButton!
    @IBOutlet weak var newModeNameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var selectedColorview: UIView!
    
    @IBOutlet weak var saveStaticVerticalConstraint: NSLayoutConstraint!
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            let newMode : Mode = Mode(name: self.textField.text!.lowercaseString)
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
            self.newModeNameLabel.textColor = UIColor.blackColor()
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
        self.newModeNameLabel.textColor = UIColor.blackColor()
        self.saveStaticVerticalConstraint.constant = 20
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force Landscape
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        colorSlider.frame = CGRectMake(0, 0, 12, 150)
        sliderContainerView.addSubview(colorSlider)
        colorSlider.previewEnabled = true
        colorSlider.addTarget(self, action: "changedColor:", forControlEvents: .ValueChanged)
        selectedColorview.backgroundColor = colorSlider.color
        self.selectedColorview.layer.borderWidth = 1
        //self.selectedColorview.layer.borderColor = UIColor.blackColor().CGColor
        
        
    }

    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.newModeNameLabel.textColor = UIColor.blackColor()
        self.saveStaticVerticalConstraint.constant = 20
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.newModeNameLabel.textColor = UIColor.blackColor()
        self.saveStaticVerticalConstraint.constant = 20
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.newModeNameLabel.textColor = UIColor.whiteColor()
        self.saveStaticVerticalConstraint.constant = 212
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.containerView.layoutIfNeeded()
        })
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
        // Do something when color changes
        
        selectedColorview.backgroundColor = slider.color
        // var color = slider.color
        // ...
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
