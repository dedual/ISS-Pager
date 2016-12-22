//
//  ISSLocation.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ISSLocation: NSObject
{
    var currLocation:CLLocation!
    var lastUpdated:Date!

    init(json:[String:AnyObject])
    {
        super.init()
        
        self.lastUpdated = Date.init(timeIntervalSince1970: (json["timestamp"] as! NSNumber).doubleValue)
        let coordinatesData = json["iss_position"] as! [String:AnyObject]
        
        let lat = (coordinatesData["latitude"] as! NSNumber).doubleValue
        let lng = (coordinatesData["longitude"] as! NSNumber).doubleValue
        
        self.currLocation = CLLocation(latitude: lat, longitude: lng)
        
    }
}
