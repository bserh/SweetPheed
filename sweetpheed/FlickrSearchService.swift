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

class FlickrSearchService {
    //MARK: - Properties
    var data = [FlickrPhotoModel]()
    var storedQueryString: String?
    var storedLocation: CLLocation?
    private var pagination = PaginationModel()
    
    //MARK: - Public Methods
    func searchNearbyPhotosWithLocation(location: CLLocation, dataHandler: ([FlickrPhotoModel]) -> ()) {
        populateParametersIfChangesPresentWith(location: location)
        
        var queryParams = [String: String]()
        queryParams["radius"] = String(1)
        queryParams["lat"] = location.coordinate.latitude.description
        queryParams["lon"] = location.coordinate.longitude.description
        
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
    
    func searchPhotosWithQueryString(queryString: String, dataHandler: ([FlickrPhotoModel]) -> ()) {
        populateParametersIfChangesPresentWith(queryString: queryString)
        
        var queryParams = [String: String]()
        queryParams["text"] = queryString
        
        let method = prepareSearchMethod(queryParams)
        
        FlickrKit.sharedFlickrKit().call(method) {
            response, error in
            
            guard response != nil else {
                NSLog("Search Photos By Keyword Method received no data. The error code \(error.code)")
                return
            }
            
            self.parseDataFromResponse(response, dataHandler: dataHandler)
        }
    }
    
    //MARK: - Private Methods
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
    
    private func prepareSearchMethod(queryParams: [String: String]) -> FKFlickrPhotosSearch {
        var params = queryParams
        params += pagination.toDictionaryRepresentation()
        pagination.currentPage += 1//increase a page for reuse
        
        let method = FKFlickrPhotosSearch()
        for (key, value) in params {
            method.setValue(value, forKey: key)
        }
        method.privacy_filter = String(1)//1 allows only public content
        
        return method
    }
    
    private func populateParametersIfChangesPresentWith(location location: CLLocation) {
        if let oldLocation = storedLocation {
            if !CLLocation.isLocationsEqual(oldLocation, location) {
                pagination = PaginationModel()
                storedLocation = location
            } else if CLLocation.isLocationsEqual(oldLocation, location) && data.count == 0 {//gets pull-to-refresh trigger
                pagination = PaginationModel()
            }
        } else {
            storedLocation = location
        }
    }
    
    private func populateParametersIfChangesPresentWith(queryString queryString: String) {
        if let oldQueryString = storedQueryString {
            if oldQueryString != queryString {
                pagination = PaginationModel()
                storedQueryString = queryString
            } else if oldQueryString == queryString && data.count == 0 {
                pagination = PaginationModel()
            }
        } else {
            storedQueryString = queryString
        }
    }
}