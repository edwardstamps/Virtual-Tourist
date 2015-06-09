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


class DetViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    var thePin : MapPin!
    var newPics : [Picture]!
    var savPics = [PinsNS]()
    var thePicPin : PinsNS!
    
    var i : Int?

    
    var theDude: Int = 0
    
    var errorString: String? = nil
    
    
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
        annotation = appDelegate.coords
        self.mapView.delegate = self
        fetchedResultsController.performFetch(nil)
//        fetchedResultsController.delegate = self

        
        i = appDelegate.i

        self.addPin()
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(imagePath) as? [PinsNS] {
            savPics = array
        }
        thePicPin = savPics[i!]
        saveButton.enabled = false
        cancelButton.enabled = false
        var error: NSError? = nil
        if (fetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)")
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSKeyedArchiver.archiveRootObject(self.savPics, toFile: imagePath)

    }
    

    
    var imagePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("objectsArray").path!
    }

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imagePath", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "imagePath",
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        }()
    
    
    
    
    func downloadImageAndSetCell(let image: Picture,let cell: UICollectionViewCell) {
        println("download happened")
        let imagePath = image.imagePath
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let mainQueue = NSOperationQueue.mainQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object. It now populates each cell and adds the image to the PinNS to be saved via NSArchiver.
                
                let imaged = UIImage(data: data)
                image.image = imaged
                let imageView = UIImageView(image: imaged)
                self.thePicPin.pictures?.append(imaged!)
                NSKeyedArchiver.archiveRootObject(self.savPics, toFile: self.imagePath)

                cell.backgroundView = imageView
            }
            else {
                println("Could not download image")
            }
        })
    }


    
    func addPin(){
        let anno = MKPointAnnotation()
        anno.coordinate = annotation
        mapView.addAnnotation(anno)

    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        
        self.newPics = self.fetchedResultsController.fetchedObjects as! [Picture]


        if newPics.count > 12 {
            dispatch_async(dispatch_get_main_queue(), {
                                self.saveButton.enabled = true
                
                            })
            return 12
        }
        else {
        
        return newPics!.count
        }
    
    }
    
   
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PicCell", forIndexPath: indexPath) as! FlickrPhotoCell
       
//        the case to call the api in case of an empty array is discussed earlier during the process of locating the correct pin on the mapview
        //What we are testing here is if the actual image has been downloaded via NSArchiver or not. If not we need to pull the imagepath from the CoreData file then open the pic.

            if thePicPin.pictures!.isEmpty {
                println("here")
                let thisPic = self.thePin.pictures[indexPath.row]
                self.downloadImageAndSetCell(thisPic, cell: cell)

        }

        else{

                var picture = thePicPin.pictures![indexPath.row]
                let imageView = UIImageView(image: picture)
                cell.backgroundView = imageView
        
        }
     
        
        return cell
 
    }



    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // This process is pretty similar to what we did earier but on a single scale. Find a new imagePath then replace that in CoreData and also in NSArchiver when it completes its download.
         var cell = collectionView.cellForItemAtIndexPath(indexPath) as! FlickrPhotoCell
        println("gooo")
        i = indexPath.row
        let randomPhotoIndex = Int(arc4random_uniform(UInt32(thePin.pictures.count)))
        let thisPic = thePin.pictures[randomPhotoIndex]
        thePin.pictures[indexPath.row].imagePath = thisPic.imagePath
        cell.backgroundView = nil
        dispatch_async(dispatch_get_main_queue(), {
        let theUrl = NSURL(string: thisPic.imagePath)
        let imageData = NSData(contentsOfURL: theUrl!)
            let image = UIImage(data: imageData!)
            let imageView = UIImageView(image: image)
            self.thePicPin.pictures?.removeAtIndex(indexPath.row)
            self.thePicPin.pictures?.insert(image!, atIndex: indexPath.row)
            
            NSKeyedArchiver.archiveRootObject(self.savPics, toFile: self.imagePath)
            
            cell.backgroundView = imageView
            thisPic.pin = nil
            })
        CoreDataStackManager.sharedInstance().saveContext()
        

        }
  
        
    @IBAction func refreshTable(sender: AnyObject) {
        
        //every imagepath(url) is being saved when we make the original flickr api call thus calling it again is unnecessary. clicking refresh activates the download of the data on the next 12 urls in the array. Also the table will never be empty since it requires atleast 24 pics to push the button. Otherwise it says No more pics.
        
        //We simply need to delete the original imagepaths and Images and recall the table. It will find no images avaiable from KeyArchiver and call again the Download and Set Function.
     
        
        var add = 0
        var i = 0

            if thePin.pictures.count > 24 {
                
                for result in thePin.pictures {
                    result.pin = nil
                    add = add + 1
                    if add > 11 {
                        thePicPin.pictures = []
                        CoreDataStackManager.sharedInstance().saveContext()
                        self.collectionView.reloadData()
//                        i++
                        return
                        
                        
                }
                }
                

        }
        
            else {
                    dispatch_async(dispatch_get_main_queue(), {
                self.errorText.text = "No Additional Pics"
                })
        }

    }

    

 
 
    @IBAction func backCommand(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }

    
}


//
//func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//    
//    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PicCell", forIndexPath: indexPath) as! UICollectionViewCell
//    
//    //        the case to call the api in case of an empty array is discussed earlier during the process of locating the correct pin on the mapview
//    
//    //        if newPics.count == 12{
//    //            let thisPic = self.newPics[indexPath.row]
//    //            let image = UIImage(data: thisPic.image)
//    //            let imageView = UIImageView(image: image)
//    //            cell.backgroundView = imageView
//    //            return cell
//    //
//    //        }
//    
//    //        if let picture = NSKeyedUnarchiver.unarchiveObjectWithFile(self.imagePath(imagePath.newPics![indexPath.row].image.lastPathComponent)) as? UIImage {
//    println("lol")
//    //        i = indexPath.row
//    //        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.imagePath(imagePath[i].pictures) as? [MapPin],{
//    if thePicPin.pictures!.isEmpty {
//        println("here")
//        let thisPic = self.thePin.pictures[indexPath.row]
//        self.downloadImageAndSetCell(thisPic, cell: cell)
//        
//        //            var yup = array[i!]
//        //            var picture = yup.pictures[indexPath.row].image
//        //            println(savPics)
//        //            let imageView = UIImageView(image: picture)
//        //            cell.backgroundView = imageView
//    }
//        //        if let picture = savPics[indexPath.row] as? UIImage {
//        ////        if savPics =! nil {
//        //
//        //            println("porqueno")
//        //            let imageView = UIImageView(image: picture)
//        //            cell.backgroundView = imageView
//        //        }
//    else{
//        //            self.savPics.append(self.thePin)
//        //        let thisPic = self.thePin.pictures[indexPath.row]
//        //                self.downloadImageAndSetCell(thisPic, cell: cell)
//        
//        println("there")
//        var picture = thePicPin.pictures![indexPath.row]
//        println(savPics)
//        //                println(thePicPin.pictures[indexPath.row])
//        let imageView = UIImageView(image: picture)
//        cell.backgroundView = imageView
//        
//        
//        
//    }
//    
//    
//    return cell
//    
//}


//    func loadPic(){
//        var i=0
//        for result in  thePin.pictures{
//            let theUrl = NSURL(string: result.pic)
//            let imageData = NSData(contentsOfURL: theUrl!)
////            result.image = imageData!
//            i++
//
//            if i>12 {
//                return
//            }
//
//
//        }
//
//    }


//    func newData() {
//        var i = 0
//        for result in thePin.pictures {
//            if i < 13 {
//                let theUrl = NSURL(string: result.imagePath)
//                let imageData = NSData(contentsOfURL: theUrl!)
////                result.image = imageData!
//                self.collectionView.reloadData()
////                self.downloadImageAndSetCell(result.imagePath, cell: UICollectionViewCell())
//                CoreDataStackManager.sharedInstance().saveContext()
//                i++
//
//            }
//
//    }
//    }

//        self.newPics = self.fetchedResultsController.fetchedObjects as! [Picture]
//        if self.thePin.pictures.count > 11{
//            dispatch_async(dispatch_get_main_queue(), {
//                self.saveButton.enabled = true
//                self.loadPic()
//            })
//        return 12
//
//        }
//
//        if self.thePin.pictures.isEmpty{
//            dispatch_async(dispatch_get_main_queue(), {
//                self.errorText.text = "No Pics for the spot"
//
//            })
//            return 0
//        }
//        else {
//        return self.thePin.pictures.count
//        }


//            let theUrl = NSURL(string: thisPic.pic)
//            let imageData = NSData(contentsOfURL: theUrl!)
//                thisPic.image = imageData!

//        let image = UIImage(data: thisPic.image)
////                thisPic.image = image
//        let imageView = UIImageView(image: image)
//                 dispatch_async(dispatch_get_main_queue(), {
//        cell.backgroundView = imageView
//                    })
//                let image = UIImage(data: imageData!)
//                NSKeyedArchiver.archiveRootObject(thisPic, toFile: self.picturesFilePath)



//    func fetchAllPins() -> [MapPin] {
//        let error: NSErrorPointer = nil
//
//        // Create the Fetch Request
//        let fetchRequest = NSFetchRequest(entityName: "MapPin")
//
//        // Execute the Fetch Request
//        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
//
//        // Check for Errors
//        if error != nil {
//            println("Error in fectchAllPins(): \(error)")
//        }
//
//
//        return results as! [MapPin]
//
//    }
//


//
//    func findPics(){
//        var i = 0
//
//        for done in self.pinot{
//
//            if annotation.longitude == done.cityCord {
//                if annotation.latitude == done.latCord {
//
//                println(i)
//                theDude = i
//                println(theDude)
//                    appDelegate.coords = annotation
//                thePin = self.pinot[theDude]
//
//                if done.pictures.isEmpty {
//
//
//                    Flickr.sharedInstance().authenticateWithViewController(self) { (success) in
//                        if success {
//                            dispatch_async(dispatch_get_main_queue(), {
//                                self.studentEntry()
//                                return
//                            })
//                        } else {
//                            self.displayError()
//                            println("wtf")
//                            return
//                }
//                    }
//
//                }
//                }
//                else {
//                    dispatch_async(dispatch_get_main_queue(), {
//                       self.saveButton.enabled = true
////                          self.collectionView.reloadData()
//
//                        return
//                    })
//
//                }
//
//
//
//        }
//            i++
//        }
//    }
//
//    func studentEntry() {
//        println("nono")
//        var parsedResult = self.appDelegate.dataStuff as! NSArray
//        var i = 0
//        if parsedResult.count == 0 {
//            self.displayError()
//        }
//
//        if parsedResult.count > 11{
////            self.collectionView.reloadData()
//        }
//
//            for result in parsedResult {
//
////                println(result)
//                let imageUrlString = result["url_m"] as! String
////                println(imageUrlString)
//                let PicToBeAdded = Picture(context: sharedContext)
//                PicToBeAdded.pic = imageUrlString
//
//                PicToBeAdded.pin = self.thePin
//                println(PicToBeAdded)
////                self.collectionView.insertItemsAtIndexPaths(thePin.pictures)
////               self.collectionView.reloadData()
//
//
//                if i<13{
//                    let theUrl = NSURL(string: PicToBeAdded.pic)
//                    let imageData = NSData(contentsOfURL: theUrl!)
//                    PicToBeAdded.image = imageData!
//                    newPics.append(PicToBeAdded)
//
//                    self.happen()
//                    println(thePin.pictures.count)
//
//
//                }
//                i++
//
//
//            }
//        CoreDataStackManager.sharedInstance().saveContext()
////        self.collectionView.reloadData()
//        dispatch_async(dispatch_get_main_queue(), {
//            self.saveButton.enabled = true
//        })
//
//        return
//
//
//    }
//
//    func happen(){
//        self.collectionView.reloadData()
//    }
//
//
//
//    func displayError() {
//        dispatch_async(dispatch_get_main_queue(), {
//            self.errorText.text = "No Pics"
//        })
//    }
    