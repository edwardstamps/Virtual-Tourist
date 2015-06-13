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
    
//    struct Keys {
//        static let Title = "title"
//        
//    }


//    @NSManaged var unique: NSNumber
    @NSManaged var pic: String
    
//    @NSManaged var nombre: String

    @NSManaged var pin: MapPin?
    
    @NSManaged var imagePath: String
 
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
    init(context: NSManagedObjectContext){
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        
    }
    
    var image: UIImage? {
        get {
            return DetViewController.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        set {
            DetViewController.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }

    
  


}