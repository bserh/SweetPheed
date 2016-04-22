//
//  CLLocationExtension.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/22/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    static func isLocationsEqual(location1: CLLocation, _ location2: CLLocation) -> Bool {
            return location1.distanceFromLocation(location2) == 0
    }
}
