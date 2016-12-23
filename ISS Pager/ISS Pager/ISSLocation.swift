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
    
    var arrivalTimes:[ISSReminderRiseAndDuration]?

    
    override init()
    {
        super.init()
    }

    init(json:[String:AnyObject])
    {
        super.init()
        self.prepareWithJSON(json: json)
    }
    
    func prepareWithJSON(json:[String:AnyObject])
    {
        self.lastUpdated = Date.init(timeIntervalSince1970: (json["timestamp"] as! NSNumber).doubleValue)
        let coordinatesData = json["iss_position"] as! [String:AnyObject]
        
        if let lat = coordinatesData["latitude"]?.doubleValue, let lng = coordinatesData["longitude"]?.doubleValue
        {
            self.currLocation = CLLocation(latitude: lat, longitude: lng)
        }
    }
    
    func arrivalTimesFor(location:CLLocation, completed: @escaping (_ finished:Bool, _ error:Error?) -> ())
    {
        ISSNetwork.request(target: .PassTimes(lat: location.coordinate.latitude, lng: location.coordinate.longitude), success: { json in
            
            if let jsonObject = json as? [String:AnyObject]
            {
                self.arrivalTimes = Array<ISSReminderRiseAndDuration>()
                
                if let responseObject = jsonObject["response"] as? [[String:AnyObject]]
                {
                    for riseTimeObject in responseObject
                    {
                        let riseTime = riseTimeObject["risetime"] as! NSNumber
                        let duration = riseTimeObject["duration"] as! NSNumber
                        
                        let arrivalTime = ISSReminderRiseAndDuration(rise: riseTime, duration: duration)
                        
                        self.arrivalTimes!.append(arrivalTime)
                    }
                }
            }
            
            completed(true, nil)

        }, error: { response in
            do{
                var errorMessage = "Network error in how we recover a pass time"
                
                if let json = try response.mapJSON() as? [String:AnyObject]
                {
                    errorMessage = json["errors"] as! String
                }
                
                // handle it further here
                completed(false, nil)
            }
            catch
            {
                // failed to even parse the response. Handle appropriately
            }
            
        }, failure: { error in
            
            // handle error here
            completed(false, error)
            
        })
    }

    
    // add pass by's based on user's location here
}
