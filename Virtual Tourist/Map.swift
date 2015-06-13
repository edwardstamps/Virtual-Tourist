//
//  Map.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/28/15.
//  Copyright (c) 2015 CheckList. All rights reserved.


import Foundation
import UIKit
import CoreData

@objc(Map)

class Map : NSManagedObject {
    @NSManaged var cityCord: NSNumber
    @NSManaged var latCord: NSNumber
    @NSManaged var zoom: NSNumber
    @NSManaged var zoom2: NSNumber
    
    
    override init( entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
    init(context: NSManagedObjectContext){
        let entity =  NSEntityDescription.entityForName("Map", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    
    }
    
}