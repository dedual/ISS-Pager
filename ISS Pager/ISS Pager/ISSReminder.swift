//
//  ISSReminder.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import CoreLocation


class ISSReminder: NSObject, NSCoding
{
    let kISSRemindersNameKey:String = "name"
    let kISSRemindersAddressKey:String = "address"
    let kISSReminderLatitudeKey:String = "latitude"
    let kISSReminderLongitudeKey:String = "longitude"
    let kISSReminderRiseTimeKey:String = "riseTime"
    let kISSReminderLastUpdatedKey:String = "lastUpdated"
    
    
    var name:String!
    var address:String!
    var latitude:Double!
    var longitude:Double!
    
    var location:CLLocation
    {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var lastUpdated:Date!
    var arrivalTimes:[[String:AnyObject]]!
    
    init(json:[String:AnyObject])
    {
        
    }
    
    required init?(coder decoder:NSCoder)
    {
        self.latitude = decoder.decodeDouble(forKey: kISSReminderLatitudeKey)
        self.longitude = decoder.decodeDouble(forKey: kISSReminderLongitudeKey)
        self.name = decoder.decodeObject(forKey: kISSRemindersNameKey) as! String
        self.lastUpdated = decoder.decodeObject(forKey: kISSReminderLastUpdatedKey) as! Date
        self.address = decoder.decodeObject(forKey: kISSRemindersAddressKey) as! String
        self.arrivalTimes = decoder.decodeObject(forKey: kISSReminderRiseTimeKey) as! [[String:AnyObject]]
        
    }
    
    func encode(with coder:NSCoder)
    {
        coder.encode(self.latitude, forKey: kISSReminderLatitudeKey)
        coder.encode(self.longitude, forKey: kISSReminderLongitudeKey)
        coder.encode(self.name, forKey: kISSRemindersNameKey)
        coder.encode(self.address, forKey: kISSRemindersAddressKey)
        coder.encode(self.lastUpdated, forKey: kISSReminderLastUpdatedKey)
        coder.encode(self.arrivalTimes, forKey: kISSReminderRiseTimeKey)
    }
}
