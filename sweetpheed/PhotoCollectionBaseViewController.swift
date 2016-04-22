//
//  PhotoCollectionBaseViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/21/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class PhotoCollectionBaseViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoSearchService = FlickrSearchService()
    private let showFullSizeSegueIdentifier = "showFullSizePhoto"
    private var refreshControl: UIRefreshControl?
    private var cacheController = CacheImageController.sharedInstance
    
    //MARK: - Life Cycle Managing Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let collectionViewCell = sender as! ImageCollectionViewCell
        let indexPath = collectionView.indexPathForCell(collectionViewCell)!
        
        let photoURL = photoSearchService.data[indexPath.row].originalURL
            
        if let photoDetailVC = segue.destinationViewController as? PhotoDetailViewController
            where segue.identifier == self.showFullSizeSegueIdentifier {
                photoDetailVC.photoURL = photoURL
        }
    }
    
    @IBAction func unwindToPhotoCollectionBaseViewController(segue: UIStoryboardSegue) {
        //programaticaly unwind back
    }

    //MARK: - Custom Methods
    func fetchData(finishCompletion: (Void -> Void)?) {//template pattern
        return
    }
    
    func handleFlickrData(responseData: [FlickrPhotoModel], finishCompletion: (Void -> Void)?) {
        var indexPaths = [NSIndexPath]()
        let firstIndex = photoSearchService.data.count
        
        for (i, photoModel) in responseData.enumerate() {
            let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
            
            photoSearchService.data.append(photoModel)
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
    
    @objc func refreshData() {
        var indexPaths = [NSIndexPath]()
        let firstIndex = 0
        
        for (i, _) in photoSearchService.data.enumerate() {
            let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
            indexPaths.append(indexPath)
        }
        
        collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths(indexPaths)
            self.photoSearchService.data = []
            self.fetchData(nil)
        }, completion: nil)
    }
    
    private func loadImageForCellInBackgroundFor(thumbURL thumbURL: NSURL, completion: (thumb: UIImage) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if let thumbImageData = NSData(contentsOfURL: thumbURL), tImage = UIImage(data: thumbImageData){
                self.cacheController.cachingImage(tImage, forKeyAsURL: thumbURL)
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(thumb: tImage)
                })
            }
        }
    }
}

//MARK: - Extension - Collection View Data Source Methods
extension PhotoCollectionBaseViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCollectionViewCell.reusableIdentifier,
            forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let cellPhotoModel = photoSearchService.data[indexPath.row]
        let thumbURL = cellPhotoModel.thumbnailURL!
        
        cell.loadingIndicator.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
        cell.loadingIndicator.hidesWhenStopped = true
        let image = cacheController.getImageByURL(thumbURL)
        
        if image == nil {
            cell.loadingIndicator.startAnimating()
            loadImageForCellInBackgroundFor(thumbURL: thumbURL) { thumbImage in
                let indexPath_ = collectionView.indexPathForCell(cell)
                if indexPath.isEqual(indexPath_) {
                    cell.imageView.image = thumbImage
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
        return photoSearchService.data.count
    }
}

//MARK: - Extension - Collection View Delegate Methods
extension PhotoCollectionBaseViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

//MARK: - Extension - Collection View Flow Layout Delegate Methods
extension PhotoCollectionBaseViewController: UICollectionViewDelegateFlowLayout {
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

