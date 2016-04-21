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

class SearchController {
    var data = [FlickrPhotoModel]()
    var storedQueryString: String?
    var storedLocation: CLLocation?
    private var pagination = PaginationModel()
    
    func searchNearbyPhotosWithLocation(location: CLLocation, dataHandler: ([FlickrPhotoModel]) -> ()) {
        populateParametersIfChangesExist(location)
        
        var queryParams = [String: CustomStringConvertible]()
        queryParams["radius"] = 1
        queryParams["lat"] = location.coordinate.latitude
        queryParams["lon"] = location.coordinate.longitude
        
        let method = prepareSearchMethod(queryParams)
        
        FlickrKit.sharedFlickrKit().call(method) {
            response, error in
            
            guard response != nil else {
                NSLog("Search Nearby Photos Method received no data. The error code \(error.code)")
                return
            }
            
            self.parseDataFromResponse(response, dataHandler: dataHandler)
        }
    }
    
    private func parseDataFromResponse(response: [NSObject: AnyObject], dataHandler: ([FlickrPhotoModel]) -> Void) {
        var flickrResponseData = [FlickrPhotoModel]()
        
        let photosContainerObject = response["photos"] as! [NSObject: AnyObject]
        let photoArray = photosContainerObject["photo"] as! [[NSObject: AnyObject]]
        for photoDictionary in photoArray {
            let photoThumbURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeSmall240, fromPhotoDictionary: photoDictionary)
            let photoOriginalURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeLarge1600, fromPhotoDictionary: photoDictionary)

            let photoModel = FlickrPhotoModel(thumbnailURL: photoThumbURL, originalURL: photoOriginalURL)
            flickrResponseData.append(photoModel)
        }
        
        dataHandler(flickrResponseData)
    }
    
    private func prepareSearchMethod(queryParams: [String: CustomStringConvertible]) -> FKFlickrPhotosSearch {
        var params = queryParams
        params += pagination.toDictionaryRepresentation()
        pagination.currentPage += 1//increase a page for reuse
        
        let method = FKFlickrPhotosSearch()
        for (key, value) in params {
            method.setValue(value.description, forKey: key)
        }
        method.privacy_filter = String(1)//1 allows only public content
        
        return method
    }
    
    private func populateParametersIfChangesExist(location: CLLocation) {
        if let oldLocation = storedLocation {
            if !isLocationsEqual(oldLocation, location) {
                self.pagination = PaginationModel()
                self.storedLocation = location
            } else if isLocationsEqual(oldLocation, location) && data.count == 0 {//gets pull-to-refresh trigger
                self.pagination = PaginationModel()
            }
        } else {
            self.storedLocation = location //initialize first if nil
        }
    }
    
    private func isLocationsEqual(location1: CLLocation, _ location2: CLLocation) -> Bool {
        return location1.distanceFromLocation(location2) == 0
    }
}