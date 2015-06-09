//
//  pinsNS.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 6/8/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation
import UIKit

@objc(PinsNS)

class PinsNS: NSObject, NSCoding {
    var title: Int?
    var pictures: [UIImage]?
    
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.pictures = decoder.decodeObjectForKey("pictures") as! [UIImage]!
        self.title = decoder.decodeObjectForKey("title") as! Int!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.pictures, forKey: "pictures")
        coder.encodeObject(self.title, forKey: "title")
    }
}

