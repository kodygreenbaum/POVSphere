//
//  StaticModeRunningViewController.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class StaticModeRunningViewController: UIViewController {

    var mode : Mode!
    private var _index : Int = 0
    
    var index : Int {
        get {return _index}
        set(newValue) { _index = newValue }
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func finishButtonPressed(sender: AnyObject) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = self.mode
        .name
        
        
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
