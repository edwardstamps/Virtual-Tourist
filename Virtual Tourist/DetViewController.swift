//
//  DetViewController.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/19/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit


class DetViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {
    
    var thePin : MapPin!
    var newPics = [Picture]()
    var otherPics = [Picture]()
    
//    var pico = [Picture]()
//    var poco = [Picture]()
    var pinot = [MapPin]()
    
    var theDude: Int = 0
    
    
    var annotation: CLLocationCoordinate2D!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var errorText: UILabel!
    
    @IBOutlet weak var refreshButton: UIToolbar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
        self.mapView.delegate = self
        pinot = fetchAllPins()
        self.addPin()
        saveButton.enabled = false
        cancelButton.enabled = false
      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func fetchAllPins() -> [MapPin] {
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "MapPin")
        
        // Execute the Fetch Request
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        // Check for Errors
        if error != nil {
            println("Error in fectchAllPins(): \(error)")
        }
        
        println(results)
       
        
        return results as! [MapPin]
        
    }
    
    
    func addPin(){
        let anno = MKPointAnnotation()
        anno.coordinate = annotation
        mapView.addAnnotation(anno)
        self.findPics()
        
    }
    
    func findPics(){
        var i = 0
        
        for done in self.pinot{
           
            if annotation.longitude == done.cityCord {
               
                
//                theDude = done
                println(i)
                theDude = i
                println(theDude)
                appDelegate.coords = annotation
                thePin = self.pinot[theDude]
                
                
                
                if done.pictures!.count < 12 {
                    Flickr.sharedInstance().authenticateWithViewController(self) { (success) in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.studentEntry()
                            })
                        } else {
                            self.displayError()
                }
                    }
                    
                }
                else {
//                    newPics = done.pictures!
                    self.saveButton.enabled = true
                    self.collectionView.reloadData()
                    println("hahahahah")
                    dispatch_async(dispatch_get_main_queue(), {
                       self.saveButton.enabled = true
                    })
                    
                }
                    
                
           
        }
            i++
        }
    }
    
    func studentEntry() {
        var parsedResult = self.appDelegate.dataStuff as! NSArray
        var i = 0
//        if parsedResult.count > 30{
//           parsedResult=parsedResult[0..<30]
//        }
            for result in parsedResult {
                i++
//                println(result)
                let imageUrlString = result["url_m"] as! String
//                println(imageUrlString)
                let PicToBeAdded = Picture(context: sharedContext)
                PicToBeAdded.pic = imageUrlString
                
//                println(PicToBeAdded)
//                newPics.append(PicToBeAdded)
                PicToBeAdded.pin = self.thePin
//                parsedResult.delete(result)
                
                
                if i > 100 {
                    CoreDataStackManager.sharedInstance().saveContext()
                    self.collectionView.reloadData()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.saveButton.enabled = true
                    })
                    
                    return
                }
               
            }
        CoreDataStackManager.sharedInstance().saveContext()
        self.collectionView.reloadData()
        dispatch_async(dispatch_get_main_queue(), {
            self.saveButton.enabled = true
        })
        
        return
  
        
    }



    
    
    func displayError() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorText.text = "No Pics"
        })
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    //similar to how we created our table but different commands for collection views
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //cells are a bit tricker from an image standpoint. We need to set the cell then use an image box in the prototype. Since cells only have backgroundviews as options we need to set it to that
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PicCell", forIndexPath: indexPath) as! UICollectionViewCell
       
//        
        if self.thePin.pictures!.count > 11 {
        let thisPic = thePin.pictures![indexPath.row]
//
//            self.pinot[theDude].pictures![0,10]
            
        let theUrl = NSURL(string: thisPic.pic)
        println(theUrl!)
        if let imageData = NSData(contentsOfURL: theUrl!) {
            dispatch_async(dispatch_get_main_queue(), {
        let image = UIImage(data: imageData)
        let imageView = UIImageView(image: image)
        cell.backgroundView = imageView
            })
            }
        }
  
        
        return cell
 
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         var cell = collectionView.cellForItemAtIndexPath(indexPath)

        let randomPhotoIndex = Int(arc4random_uniform(UInt32(thePin.pictures!.count)))
        let thisPic = thePin.pictures![randomPhotoIndex]
        thePin.pictures![indexPath.row].pic = thisPic.pic
        CoreDataStackManager.sharedInstance().saveContext()


        let theUrl = NSURL(string: thisPic.pic)
        println(theUrl!)
        if let imageData = NSData(contentsOfURL: theUrl!) {
            dispatch_async(dispatch_get_main_queue(), {
                let image = UIImage(data: imageData)
                let imageView = UIImageView(image: image)
                
                cell!.backgroundView = imageView
              
                
                
                
            })
        }
    }
        
    @IBAction func refreshTable(sender: AnyObject) {
     
        
        var add = 0
//        
//            newPics = [Picture]()
            if thePin.pictures!.count > 23 {
                
                for result in thePin.pictures! {
                    add = add + 1
                    if add > 11 {
                        thePin.pictures = nil
                        otherPics.append(result)
                        result.pin = self.thePin
              
                }
                }

                CoreDataStackManager.sharedInstance().saveContext()
                self.collectionView.reloadData()
                return
        }
        
        

      
        else{
            self.errorText.text = "No Additional Pics"
        }
    }
 
 
    @IBAction func backCommand(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
}