//
//  NearbyPhotosViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyPhotosViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let locationManager = CLLocationManager()
    private let photoSearchController = SearchController()
    private var refreshControl: UIRefreshControl?
    private var lastLocationPoint: CLLocation?
    private var automaticalyUpdatePermission = false
    private var numberOfSections = 0
    private var cache = NSCache()
    
    //MARK: - Life Cycle Managing Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
        refresher.tintColor = UIColor.darkGrayColor()
        self.refreshControl = refresher

        collectionView.addSubview(refreshControl!)
        collectionView.alwaysBounceVertical = true
        
        collectionView.addInfiniteScrollWithHandler {
            [weak self] scrollView in
            self?.fetchData() {
                scrollView.finishInfiniteScroll()
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func onUpdateSwitchChanged(sender: UISwitch) {
        automaticalyUpdatePermission = sender.on
    }
    
    //MARK: - Custom Methods
    private func fetchData(finishCompletion: (Void -> Void)?) {
        guard let lastLocationPoint = lastLocationPoint else {
            return
        }
        
        photoSearchController.searchNearbyPhotosWithLocation(lastLocationPoint, dataHandler: {
            [unowned self] data in
            self.handleFlickrData(data, finishCompletion: finishCompletion)
        })
    }
    
    private func handleFlickrData(responseData: [FlickrPhotoModel], finishCompletion: (Void -> Void)?) {
        var indexPaths = [NSIndexPath]()
        let firstIndex = photoSearchController.data.count
        
        for (i, photoModel) in responseData.enumerate() {
            let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
            
            photoSearchController.data.append(photoModel)
            indexPaths.append(indexPath)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItemsAtIndexPaths(indexPaths)
            }, completion: {
                finished in
                finishCompletion?()
            })
            
            if let refreshState = self.refreshControl?.refreshing {
                if refreshState {
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    @objc private func refreshData() {
        var indexPaths = [NSIndexPath]()
        let firstIndex = 0
        
        for (i, _) in photoSearchController.data.enumerate() {
            let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
            indexPaths.append(indexPath)
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths(indexPaths)
            self.photoSearchController.data = []
            self.fetchData(nil)
        }, completion: nil)
    }
    
    private func loadImageForCellInBackgroundByURL(URL: NSURL, completion: (image: UIImage) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if let imageData = NSData(contentsOfURL: URL), image = UIImage(data: imageData) {
                dispatch_async(dispatch_get_main_queue(), {
                    completion(image: image)
                })
            }
        }
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

//MARK: - Extension - Collection View Data Source Methods
extension NearbyPhotosViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCollectionViewCell.reusableIdentifier,
            forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let cellPhotoModel = photoSearchController.data[indexPath.row]
        let thumbURL = cellPhotoModel.thumbnailURL!
        
        cell.loadingIndicator.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
        cell.loadingIndicator.hidesWhenStopped = true
        let image = cache.objectForKey(thumbURL) as? UIImage
        
        if image == nil {
            cell.loadingIndicator.startAnimating()
            loadImageForCellInBackgroundByURL(thumbURL) {
                image in
                
                let indexPath_ = collectionView.indexPathForCell(cell)
                if indexPath.isEqual(indexPath_) {
                    cell.imageView.image = image
                    cell.loadingIndicator.stopAnimating()
                }
            }
        } else {
            cell.imageView.image = image! as UIImage
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoSearchController.data.count
    }
}

//MARK: - Extension - Collection View Flow Layout Delegate Methods
extension NearbyPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth = UIScreen.mainScreen().bounds.size.width / 3 - 7
        
        return CGSizeMake(itemWidth, itemWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
}

