//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/18/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var actInd: UIActivityIndicatorView!
   
    
    var pins = [MapPin]()
    var pinned = [PinsNS]()
    
    var pino = MapPin()
    
    var locale = [Map]()
    
    var thePin: MapPin!
    
    var pin: CLLocationCoordinate2D!
    
    var regionRadius: CLLocationDistance = 9000000

    
    @IBOutlet weak var errorLabel: UILabel!
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        self.mapView.delegate = self
//        self.getMapSpots()
        locale = getMapSpots()
         self.firstZoom()
       
        let initialLocation = CLLocation(latitude: locale.last!.latCord as! Double, longitude: locale.last!.cityCord as! Double)
        let initialZoom = MKCoordinateSpanMake(locale.last!.zoom as Double, locale.last!.zoom2 as Double)
      
        centerMapOnLocation(initialLocation, span: initialZoom)
        pins = fetchAllPins()
        self.addPin()
        self.getPins()
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
        dispatch_async(dispatch_get_main_queue(), {
            self.errorLabel.text = "Error Downloading Pins"
        })
        
    }

        println(results)
       
        return results as! [MapPin]
        
    }
    


    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        self.pin = view.annotation.coordinate
        println(pin)
        appDelegate.coords = view.annotation.coordinate
        
        println(appDelegate.coords)
        actInd.startAnimating()
        actInd.hidden = false
        
        self.findPics()
        
        
    }
    
   
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        let initial = Map(context: sharedContext)
        initial.cityCord = mapView.region.center.longitude
        initial.latCord = mapView.region.center.latitude
        initial.zoom = mapView.region.span.latitudeDelta
        initial.zoom2 = mapView.region.span.longitudeDelta
        self.locale.append(initial)
        println(mapView.region.center.latitude)
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    func getPins(){
 
        for Map in self.pins{
            var longitude = Map.cityCord as! Double
            var latitude = Map.latCord as! Double
            var loordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = loordinate
            mapView.addAnnotation(annotation)
        }
        
 }
    func addPin() {
        var lpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        lpgr.minimumPressDuration = 1.5;
        
        mapView.addGestureRecognizer(lpgr)
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        
        //we are not creating the empty PinsNS file that is associated with the new pin. Since the spot in the array will be the same for the pin and PinNS we can always find the correct saved images as long as we know the spot in the array.

        if gestureRecognizer.state != .Began { return }
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        mapView.addAnnotation(annotation)
        
        let pinToBeAdded = MapPin(context: sharedContext)
        pinToBeAdded.cityCord = touchMapCoordinate.longitude
        pinToBeAdded.latCord = touchMapCoordinate.latitude

        self.appDelegate.unique = touchMapCoordinate.longitude
         self.pins.append(pinToBeAdded)

        let pino = PinsNS()
        pino.title = (pins.count - 1)
        pino.pictures = []
        
        self.pinned.append(pino)
        
        NSKeyedArchiver.archiveRootObject(self.pinned, toFile: self.imagePath)

        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    func centerMapOnLocation(location: CLLocation, span: MKCoordinateSpan) {
        let coordinateRegion = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func firstZoom(){
        if locale.isEmpty {
        let initial = Map(context: sharedContext)
        initial.cityCord = -157.829444
        initial.latCord = 21.282778
        initial.zoom = 100
            initial.zoom2 = 100
        self.locale.append(initial)
        }
    }
    
    func getMapSpots() -> [Map] {
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Map")
        
        // Execute the Fetch Request
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        // Check for Errors
        if error != nil {
            println("Error in fectchAllPins(): \(error)")
            dispatch_async(dispatch_get_main_queue(), {
                self.errorLabel.text = "Error Downloading Location"
            })
        }

        return results as! [Map]
    }
    
    
    func findPics(){
        //we use this function to help us locate the spot in the array of the pin and also for the NSArchiver file of pictures. We then use the appDelegate to save that number for use in our collectionview.
        
        var i = 0
        
        for done in self.pins{
            
            if pin.longitude == done.cityCord {
                if pin.latitude == done.latCord {
                    
                    println(i)
                    thePin = self.pins[i]
                    appDelegate.i = i
                    if done.pictures.isEmpty {
                       
                        
                        Flickr.sharedInstance().authenticateWithViewController(self) { (success) in
                            if success {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.studentEntry()
                                    

                                    return
                                })
                            } else {
                                self.displayError()
                                
                                println("wtf")
                                return
                            }
                        }
                        
                        
                    }
                    else {
                self.happen()
                
                
                return
                    }
                
                
                }
                
                
                
            }
            i++
        }
    }
    
    func studentEntry() {
        println("nono")
        var parsedResult = self.appDelegate.dataStuff as! NSArray
        var i = 0
        if parsedResult.count == 0 {
            self.displayError()
        }
        
 
        
        for result in parsedResult {
 
            let imageUrlString = result["url_m"] as! String
            let PicToBeAdded = Picture(context: sharedContext)
            PicToBeAdded.imagePath = imageUrlString
            
            PicToBeAdded.pin = self.thePin
            i++
            
            
        }
        
        self.happen()
        CoreDataStackManager.sharedInstance().saveContext()
    
        
        return
        
        
    }
    
    func happen(){

        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("DetViewController")! as! DetViewController
        detailController.thePin = self.thePin
        
        self.navigationController!.pushViewController(detailController, animated: true)
        actInd.stopAnimating()
    }
    
    
    
    func displayError() {
        dispatch_async(dispatch_get_main_queue(), {
            self.appDelegate.error = "No Pics"
        })
    }
    
    
    var imagePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("objectsArray").path!
    }

  
    
    
}
