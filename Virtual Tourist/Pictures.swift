//
//  Pictures.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/19/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation
import UIKit
import CoreData


@objc(Picture)

class Picture: NSManagedObject {


//    @NSManaged var unique: NSNumber
    @NSManaged var pic: String
    @NSManaged var image: NSData
    @NSManaged var nombre: String

    @NSManaged var pin: MapPin
   
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    init(context: NSManagedObjectContext){
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        
        
    }
    


}