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
    private var _modeByte : UInt8 = 4
    
    
    
    init(name : String, modeByte : UInt8) {
        self._name = name
        self._modeByte = modeByte
    }
    
    var name : String {
        get {return _name}
        set(newValue) {_name = newValue}
    }
    
    var modeByte : UInt8 {
        get {return _modeByte}
        set(newValue) {_modeByte = newValue}
    }
    
}
