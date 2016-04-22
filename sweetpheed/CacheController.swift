//
//  CacheController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/22/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation


class CacheImageController {
    static let sharedInstance = CacheImageController()
    
    private var cache = NSCache()
    
    private init() {
        
    }
    
    func cachingImage(image: UIImage, forKeyAsURL key: NSURL) {
        cache.setObject(image, forKey: key)
    }
    
    func getImageByURL(URL: NSURL) -> UIImage? {
        return cache.objectForKey(URL) as? UIImage
    }
}