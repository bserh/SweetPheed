//
//  PhotoDetailViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/21/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    
    private let defaultPlaceholderImageKeyName = "imageNotFound"
    private let unwindSegueIdentifier = "unwindToPhotoCollection"
    
    var photoImage: UIImage?
    private var lastZoomScale: CGFloat = -1
    
    override func viewDidLoad() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "zoom:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let image = photoImage {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: defaultPlaceholderImageKeyName)
        }
        activityIndicator.stopAnimating()
        
        scrollView.delegate = self
        updateZoom()
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    @IBAction func handleDoubleTap(sender: UITapGestureRecognizer) {
//        let kindOfTap = sender.tap
        self.performSegueWithIdentifier(unwindSegueIdentifier, sender: self)
    }
    
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
    
    private func zoom(tapGesture: UITapGestureRecognizer) {
        if (scrollView.zoomScale == self.scrollView.minimumZoomScale) {
            let center = tapGesture.locationInView(scrollView)
            let size = self.imageView.image?.size
            let zoomRect = CGRectMake(center.x, center.y, (size!.width / 2), (size!.height / 2))
            
            scrollView.zoomToRect(zoomRect, animated: true)
        } else {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
        }
    }
}
