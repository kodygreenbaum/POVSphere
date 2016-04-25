//
//  StaticModeSelectViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/7/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import CoreBluetooth

private let reuseIdentifier = "StaticCell"
private let reuseIdentifierNoIcon = "StaticCellNoIcon"

class StaticModeSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var staticModes : [Mode] = [Mode]()
    var selectedMode : Mode!
    var selectedIndex : Int!

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    @IBAction func handleSwipe(sender: AnyObject) {
        self.tabBarController!.selectedIndex = 1
    }
    
    @IBAction func handleLongPress(sender: AnyObject) {
        
        if(longPress.state == .Began) {
            let ind = collectionView.indexPathForItemAtPoint(longPress.locationInView(collectionView))
            if(ind?.item > 2) {
                let alertController = UIAlertController(title: "Delete Your Art", message:
                    "Would you like to delete your masterpiece?", preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(
                    title: "No",
                    style: UIAlertActionStyle.Default) { (action) in
                }
                let confirmAction = UIAlertAction(
                    title: "Yes",
                    style: UIAlertActionStyle.Destructive) { (action) in
                        self.staticModes.removeAtIndex((ind?.item)!)
                        self.collectionView.reloadData()
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.clearColor()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        if (staticModes.count < 1) {
            self.populateStaticModeArray()
        }
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.staticModes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if((UIImage(named: staticModes[indexPath.item].name)) != nil) {
            let cell : StaticModeCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StaticModeCollectionViewCell
            cell.imageView.image = UIImage(named: staticModes[indexPath.item].name)!
            return cell
        } else {
            let cell : StaticModeNoIconCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierNoIcon, forIndexPath: indexPath) as! StaticModeNoIconCollectionViewCell
            cell.name.text = staticModes[indexPath.item].name
        
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedMode = staticModes[indexPath.item]
        self.selectedIndex = indexPath.item
        self.performSegueWithIdentifier("static", sender: self)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    
    // MARK: Helper Methods
    
    /*
    * Generate Mode objects and populate
    * static/dynamic mode arrays
    */
    func populateStaticModeArray() {
        // Check Userdefaults first
        
        // if UserDefaults empty, hardcode fill arrays here
        // remember to set one of the modes as the default
        staticModes.append(Mode(name: "globe", modeByte: 2))
        staticModes.append(Mode(name: "wisco", modeByte: 4))
        staticModes.append(Mode(name: "weather", modeByte: 5))
        staticModes.append(Mode(name: "alarm clock", modeByte: 6))
    }
    
    
    
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "static") {
            let destination : StaticModeRunningViewController = segue.destinationViewController as! StaticModeRunningViewController
                destination.mode = self.selectedMode
                destination.index = self.selectedIndex
            // Write to Globe to start mode
            if let data: NSData? = NSData(bytes: &self.selectedMode.modeByte, length: 1) {
                if(modeChar != nil) {
                    periph.writeValue(data!, forCharacteristic: modeChar, type: CBCharacteristicWriteType.WithResponse)
                }
            }
        }
    }
    

}
