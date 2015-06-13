//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/18/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation

import UIKit
import CoreData

@objc(MapPin)

class MapPin : NSManagedObject {

    @NSManaged var unique: NSDate
    
    @NSManaged var cityCord: NSNumber
    @NSManaged var latCord: NSNumber
    @NSManaged var zoom: NSNumber

    @NSManaged var pictures: [Picture]?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
       
    }
    init(context: NSManagedObjectContext){
        let entity =  NSEntityDescription.entityForName("MapPin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    
}
