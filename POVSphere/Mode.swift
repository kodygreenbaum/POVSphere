//
//  Mode.swift
//  POVSphere
//
//  Created by Kody Greenbaum on 3/2/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit

class Mode: NSObject {

    private var _name : String = ""
    
    init(name : String) {
        self._name = name
    }
    
    var name : String {
        get {return _name}
        set(newValue) {_name = newValue}
    }
    
}
