//
//  NearbyPhotosViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyPhotosViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var previousPoint: CLLocation?
    private let photoSearchController = SearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        NSLog("Authorization status changed to \(status.rawValue)")
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let errorType = error.code == CLError.Denied.rawValue ? "Access Denied" : "Error with code = \(error.code)"
        
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        alertController.addAction(actionOK)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            previousPoint = newLocation
        }
    }
}
