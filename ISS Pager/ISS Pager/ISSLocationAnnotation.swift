//
//  ISSLocationAnnotation.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ISSLocationAnnotation: NSObject, MKAnnotation
{
    var identifier: String!
    var issLocation:ISSLocation!
    
    var coordinate:CLLocationCoordinate2D
    
    var title:String?
    {
        return "Last updated: \(issLocation.lastUpdated.humanReadableDate)"
    }
    
    
    init(coordinate:CLLocationCoordinate2D, identifier:String, location:ISSLocation)
    {
        self.coordinate = coordinate
        self.identifier = identifier
        self.issLocation = location
    }
    
}
