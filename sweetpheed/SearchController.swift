//
//  FlickrPhotoSearcher.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation
import CoreLocation
import FlickrKit

extension Int {
    var km: Int {
        return self * 1000
    }
}

class SearchController {
    private var pagination = PaginationModel()
    
    func searchNearbyPhotosWithLocation(location: CLLocation, completionHandler: ([FlickrPhotoModel]) -> Void) {
        var queryParams = [String: CustomStringConvertible]()
        queryParams["radius"] = 1.km
        queryParams["lat"] = location.coordinate.latitude
        queryParams["lon"] = location.coordinate.longitude
        
        let method = prepareSearchMethod(queryParams)
        
        FlickrKit.sharedFlickrKit().call(method) {
            response, error in
            
            guard response != nil else {
                NSLog("Search Nearby Photos Method received no data. The error code \(error.code)")
                return
            }
            
            self.parseDataFromResponse(response, completionHandler: completionHandler)
        }
    }
    
    private func parseDataFromResponse(response: [NSObject: AnyObject], completionHandler: ([FlickrPhotoModel]) -> Void) {
        let photos = response["photos"] as! [NSObject: AnyObject]
        
    }
    
    private func prepareSearchMethod(args: [String: CustomStringConvertible]) -> FKFlickrPhotosSearch {
        let method = FKFlickrPhotosSearch()
        for (key, value) in args {
            method.setValue(value.description, forKey: key)
        }
        
        method.privacy_filter = String(1)//1 allows only public content
        
        return method
    }
}