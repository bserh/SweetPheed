//
//  ImageCollectionViewCell.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/19/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    static let reusableIdentifier = "collectionViewReusableIdentifier"
    
    //MARK: - Overrided Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
