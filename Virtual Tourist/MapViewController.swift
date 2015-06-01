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
    
   
    
    var pins = [MapPin]()
    
    var locale = [Map]()
    
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
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("DetViewController")! as! DetViewController
        detailController.annotation = view.annotation.coordinate
        self.navigationController!.pushViewController(detailController, animated: true)
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
        
        println("long press")
        
//        if gestureRecognizer != UIGestureRecognizerStateBegan {
//        return;
//        }
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
        
//        let info = Picture(context: sharedContext)
//        info.unique = touchMapCoordinate.longitude
        
        self.pins.append(pinToBeAdded)
        println(self.pins)
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
        
        println(results)
        
        return results as! [Map]
    }
    
  
    
    
}
