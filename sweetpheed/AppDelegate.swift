//
//  AppDelegate.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit
import FlickrKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let apiKey = "4e6b5786a8e956ba3ec3f41a2fce4ce2"
        let secret = "9eb4d7e6f0cb391a"
        FlickrKit.sharedFlickrKit().initializeWithAPIKey(apiKey, sharedSecret: secret)
        
        return true
    }
}

