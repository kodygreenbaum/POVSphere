//
//  ModeSelectViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/7/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class ModeSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var staticModes : [Mode] = [Mode]()
    var dynamicModes : [Mode] = [Mode]()
    var selectedIndex : Int!
    // MARK: Outlets and Actions
    @IBOutlet weak var tableview: UITableView!
    
    @IBAction func disconnectButtonPressed(sender: AnyObject) {
        bleManager.centralManager.cancelPeripheralConnection(periph)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: View LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        populateModeArrays()
    }
    
    // Refresh tableview in case new static mode was saved
    // During dynamic art mode
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.tableview.reloadData()
    }
    
    // MARK: TableView Delegate/Datasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //First section Static Modes, second Dynamic Modes
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return staticModes.count
        } else if (section == 1) {
            return dynamicModes.count
        }
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ModeSelectTableViewCell! = tableView.dequeueReusableCellWithIdentifier("ModeSelectTableViewCell", forIndexPath: indexPath) as? ModeSelectTableViewCell
    
        if (indexPath.section == 0) {
            cell.nameLabel.text = staticModes[indexPath.row].name
        } else if (indexPath.section == 1) {
            cell.nameLabel.text = dynamicModes[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.row
        if (indexPath.section == 0) {
            self.performSegueWithIdentifier("static", sender: self)
        } else {
            self.performSegueWithIdentifier(dynamicModes[indexPath.row].name, sender: self)
        }
    }
    
    // MARK: Helper Methods
    
    /*
    * Generate Mode objects and populate
    * static/dynamic mode arrays
    */
    func populateModeArrays() {
        // Check Userdefaults first
        
        // if UserDefaults empty, hardcode fill arrays here
        // remember to set one of the modes as the default
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if (segue.identifier == "static") {
            let destination : StaticModeRunningViewController = segue.destinationViewController as! StaticModeRunningViewController
            destination.mode = self.staticModes[self.selectedIndex]
            destination.index = self.selectedIndex
        }
    }

}
