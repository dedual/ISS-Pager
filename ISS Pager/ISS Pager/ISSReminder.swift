//
//  ISSReminder.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ISSReminderRiseAndDuration:NSObject, NSCoding
{
    let kISSReminderRiseTimeKey = "riseTime"
    let kISSRemindeDurationKey = "duration"
    
    var riseTime:Date!
    var duration:Double! // in seconds
    
    init(rise:NSNumber, duration:NSNumber)
    {
        self.riseTime = Date(timeIntervalSince1970: rise.doubleValue)
        self.duration = duration.doubleValue
    }
    required init?(coder decoder:NSCoder)
    {
        self.duration = decoder.decodeDouble(forKey: kISSRemindeDurationKey)
        self.riseTime = decoder.decodeObject(forKey: kISSReminderRiseTimeKey) as! Date
    }
    func encode(with coder:NSCoder)
    {
        coder.encode(self.duration, forKey: kISSRemindeDurationKey)
        coder.encode(self.riseTime, forKey: kISSReminderRiseTimeKey)
    }
}

class ISSReminder: NSObject, NSCoding
{
    let kISSRemindersNameKey:String = "name"
    let kISSRemindersAddressKey:String = "address"
    let kISSReminderLatitudeKey:String = "latitude"
    let kISSReminderLongitudeKey:String = "longitude"
    let kISSReminderRiseTimeArrayKey:String = "riseTimeArray"
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
    var arrivalTimes:[ISSReminderRiseAndDuration]!
    
    init(json:[String:AnyObject])
    {
        super.init()
        
        let requestObject = json["request"] as! [String:AnyObject]
        
        self.lastUpdated = Date.init(timeIntervalSince1970: (requestObject["datetime"] as! NSNumber).doubleValue)
        self.latitude = (requestObject["latitude"] as! NSNumber).doubleValue
        self.longitude = (requestObject["latitude"] as! NSNumber).doubleValue
        
        // address should be entered after forward geocoding. Let's not do that here
        // same with name
        
        arrivalTimes = Array<ISSReminderRiseAndDuration>()
        
        if let responseObject = json["response"] as? [[String:AnyObject]]
        {
            for riseTimeObject in responseObject
            {
                let riseTime = riseTimeObject["risetime"] as! NSNumber
                let duration = riseTimeObject["duration"] as! NSNumber
                
                let arrivalTime = ISSReminderRiseAndDuration(rise: riseTime, duration: duration)
                
                arrivalTimes.append(arrivalTime)
            }
        }
    }
    
    required init?(coder decoder:NSCoder)
    {
        self.latitude = decoder.decodeDouble(forKey: kISSReminderLatitudeKey)
        self.longitude = decoder.decodeDouble(forKey: kISSReminderLongitudeKey)
        self.name = decoder.decodeObject(forKey: kISSRemindersNameKey) as! String
        self.lastUpdated = decoder.decodeObject(forKey: kISSReminderLastUpdatedKey) as! Date
        self.address = decoder.decodeObject(forKey: kISSRemindersAddressKey) as! String
        self.arrivalTimes = decoder.decodeObject(forKey: kISSReminderRiseTimeArrayKey) as! [ISSReminderRiseAndDuration]
        
    }
    
    func encode(with coder:NSCoder)
    {
        coder.encode(self.latitude, forKey: kISSReminderLatitudeKey)
        coder.encode(self.longitude, forKey: kISSReminderLongitudeKey)
        coder.encode(self.name, forKey: kISSRemindersNameKey)
        coder.encode(self.address, forKey: kISSRemindersAddressKey)
        coder.encode(self.lastUpdated, forKey: kISSReminderLastUpdatedKey)
        coder.encode(self.arrivalTimes, forKey: kISSReminderRiseTimeArrayKey)
    }
}
