//
//  ISSReminderAnnotation.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData


class ISSReminderAnnotation: NSObject, MKAnnotation
{
    var identifier: String!
    var reminder:ISSReminder!
    
    var coordinate:CLLocationCoordinate2D
    
    var title:String?
    {
        if let name = reminder.name
        {
            return name
        }
        else
        {
            return nil
        }
    }
    
    var subtitle: String?
    {
        return "Earliest arrival: \(reminder.arrivalTimes![0].riseTime.humanReadableDate)"
    }

    init(coordinate:CLLocationCoordinate2D, identifier:String, reminder:ISSReminder)
    {
        self.coordinate = coordinate
        self.identifier = identifier
        self.reminder = reminder
    }
    
}
