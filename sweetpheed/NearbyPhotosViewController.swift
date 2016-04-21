//
//  NearbyPhotosViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyPhotosViewController: PhotoCollectionBaseViewController {
    //MARK: - Properties    
    private let locationManager = CLLocationManager()
    private var lastLocationPoint: CLLocation?
    private var automaticalyUpdatePermission = false
    
    //MARK: - Life Cycle Managing Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: - Actions
    @IBAction func onUpdateSwitchChanged(sender: UISwitch) {
        automaticalyUpdatePermission = sender.on
    }
    
    //MARK: - Custom Methods
    override func fetchData(finishCompletion: (Void -> Void)?) {
        guard let lastLocationPoint = lastLocationPoint else {
            return
        }
        
        photoSearchController.searchNearbyPhotosWithLocation(lastLocationPoint, dataHandler: {
            [weak self] data in
            self?.handleFlickrData(data, finishCompletion: finishCompletion)
        })
    }
}

//MARK: - Extension - Location Manager Delegate Methods
extension NearbyPhotosViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocationPoint = lastLocationPoint, newLocation = locations.last else {
            self.lastLocationPoint = locations.last
            fetchData(nil)
            return
        }
        
        if automaticalyUpdatePermission
            && (newLocation.coordinate.latitude != lastLocationPoint.coordinate.latitude)
            && (newLocation.coordinate.longitude != lastLocationPoint.coordinate.longitude) {
            self.lastLocationPoint = newLocation
            refreshData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let errorType = error.code == CLError.Denied.rawValue ? "Access Denied" : "Error. Can't get your location"
        
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(actionOK)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

