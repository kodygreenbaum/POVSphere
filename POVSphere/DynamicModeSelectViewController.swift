//
//  DynamicModeSelectViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/7/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DynamicCell"

class DynamicModeSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var dynamicModes : [Mode] = [Mode]()
    var selectedMode : Mode!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func handleSwipe(sender: AnyObject) {
        self.tabBarController!.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.clearColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "processBLE:", name: "processBLE", object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        if (dynamicModes.count < 1) {
           populateDynamicModeArray()
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
        return self.dynamicModes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : DynamicModeCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DynamicModeCollectionViewCell
        cell.imageView.image = UIImage(named: dynamicModes[indexPath.item].name)!
        
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedMode = dynamicModes[indexPath.item]
        switch (self.selectedMode.name) {
            case "paint":
                self.performSegueWithIdentifier("paint", sender: self)
            break;

            default:
            break;
         }
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
    func populateDynamicModeArray() {
        // Check Userdefaults first
        
        // if UserDefaults empty, hardcode fill arrays here
        // remember to set one of the modes as the default
        
        dynamicModes.append(Mode(name: "paint", modeByte: 1))
        
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
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "art") {
            //let destination : ArtModeViewController = segue.destinationViewController as! ArtModeViewController
        }
    }
    

}
