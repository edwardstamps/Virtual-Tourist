//
//  Flickr.swift
//  Virtual Tourist
//
//  Created by Edward Stamps on 5/19/15.
//  Copyright (c) 2015 CheckList. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Flickr: NSObject {
    
    var thePin : MapPin!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "08f89a20636b58be8c6b7b2c3bd4555c"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 0.2
    let BOUNDING_BOX_HALF_HEIGHT = 0.2

    /* Shared session */
    var photosArray = [Picture]()
    var session: NSURLSession
    var appDelegate: AppDelegate!
    
    
    override init() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        super.init()
    }
    
  
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool) -> Void) {
        self.getFlicks() { (success) in
            completionHandler(success: success)
        }
    }
    
    func getFlicks(completionHandler: (success: Bool) -> Void){
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        /* 2 - Call the Flickr API with these arguments */
        getImageFromFlickrBySearch(methodArguments, completionHandler: completionHandler)
       
        
    
    }
    
    func createBoundingBoxString() -> String {
        let latitude = self.appDelegate.coords!.latitude
        let longitude = self.appDelegate.coords!.longitude
        
        return "\(longitude - BOUNDING_BOX_HALF_WIDTH),\(latitude - BOUNDING_BOX_HALF_HEIGHT),\(longitude + BOUNDING_BOX_HALF_WIDTH),\(latitude + BOUNDING_BOX_HALF_HEIGHT)"
    }

func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completionHandler: (success: Bool) -> Void) {
    
    let session = NSURLSession.sharedSession()
    let urlString = BASE_URL + escapedParameters(methodArguments)
    let url = NSURL(string: urlString)!
    let request = NSURLRequest(URL: url)
    
    let task = session.dataTaskWithRequest(request) {data, response, downloadError in
        if let error = downloadError {
            println("Could not complete the request \(error)")
        } else {
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                
                
                var totalPhotosVal = 0
                if let totalPhotos = photosDictionary["total"] as? String {
                    totalPhotosVal = (totalPhotos as NSString).integerValue
                }
                
                if totalPhotosVal > 0 {
                    if var photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                        
                     
                     
                        self.appDelegate.dataStuff = photosArray
                        completionHandler(success: true)
//                        
//                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                        let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                        
//                        let photoTitle = photoDictionary["title"] as? String
//                        let imageUrlString = photoDictionary["url_m"] as? String
//                        let imageURL = NSURL(string: imageUrlString!)
//                        if let imageData = NSData(contentsOfURL: imageURL!) {
//                            dispatch_async(dispatch_get_main_queue(), {
//
//                                
//                                completionHandler(success: true)
//                          
//                            })
//                        } 
//                        else {
//                            println("Image does not exist at \(imageURL)")
//                        }
                    } else {
                        println("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
//                    dispatch_async(dispatch_get_main_queue(), {
                         self.appDelegate.error = "No Photos Found. Search Again."
                        //   self.defaultLabel.alpha = 1.0
                      //  self.imagePickerView.image = nil
//                    })
                }
            } else {
                println("Cant find key 'photos' in \(parsedResult)")
            }
        }
    }
    
    task.resume()
}

/* Helper function: Given a dictionary of parameters, convert to a string for a url */
func escapedParameters(parameters: [String : AnyObject]) -> String {
    
    var urlVars = [String]()
    
    for (key, value) in parameters {
        
        /* Make sure that it is a string value */
        let stringValue = "\(value)"
        
        /* Escape it */
        let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* FIX: Replace spaces with '+' */
        let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        /* Append it */
        urlVars += [key + "=" + "\(replaceSpaceValue)"]
    }
    
    return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
}
    
    class func sharedInstance() -> Flickr {
        
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }
    
}
