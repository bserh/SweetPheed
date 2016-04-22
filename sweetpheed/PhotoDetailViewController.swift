//
//  PhotoDetailViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/21/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var singleTap: UIGestureRecognizer!
    @IBOutlet weak var doubleTap: UIGestureRecognizer!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    private let defaultPlaceholderImageKeyName = "placeholder"
    private let unwindSegueIdentifier = "unwindToPhotoCollection"
    private let cacheController = CacheImageController.sharedInstance
    
    var photoURL: NSURL?
    private var lastZoomScale: CGFloat = -1
    
    //MARK: - Life Cycle Managing Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        if let image = cacheController.getImageByURL(photoURL!) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: defaultPlaceholderImageKeyName)
        }
        
        updateZoom()
        updateConstraints()
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
        download()
    }
    
    //MARK: - Scroll View Delegate Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    //MARK: - Actions
    @IBAction func handleDoubleTap(sender: UITapGestureRecognizer) {
        handleZoomCallEvent(sender)
    }
    
    @IBAction func handleSingleTap(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(unwindSegueIdentifier, sender: self)
    }
    
    //MARK: - Custom Methods
    private func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 {
                hPadding = 0
            }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 {
                vPadding = 0
            }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    
    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width, scrollView.bounds.size.height / image.size.height)
            if minZoom > 1 {
                minZoom = 1
            }
            
            scrollView.minimumZoomScale = minZoom
            scrollView.maximumZoomScale = 2
            
            scrollView.zoomScale = minZoom
            lastZoomScale = minZoom
        }
    }
    
    private func handleZoomCallEvent(tapGesture: UITapGestureRecognizer) {
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            let center = tapGesture.locationInView(scrollView)
            let size = self.imageView.image?.size
            let zoomRect = CGRectMake(center.x, center.y, size!.width / 2, size!.height / 2)
            
            scrollView.zoomToRect(zoomRect, animated: true)
        } else {
            self.scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
}

//MARK: - Extension - Session Delegate and Session Download Delegate Methods
extension PhotoDetailViewController: NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    func download() {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTaskWithURL(photoURL!)
        
        downloadTask.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let data = NSData(contentsOfURL: location)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.hidden = true
            
            let image = UIImage(data: data!)
            self.cacheController.cachingImage(image!, forKeyAsURL: self.photoURL!)
            self.imageView.image = image
            
            self.updateZoom()
            self.updateConstraints()
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = progress
        }
    }
}
