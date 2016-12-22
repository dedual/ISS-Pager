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


class ISSReminderAnnotation: NSObject, NSCoding, MKAnnotation
{
    let kISSReminderLatitudeKey:String = "latitude"
    let kISSReminderLongitudeKey:String = "longitude"
    let kISSReminderRiseTimeKey:String = "riseTime"
    let kISSReminderNameKey:String = "reminderName"
    let kISSReminderIdentifierKey:String = "identifier"

    var coordinate: CLLocationCoordinate2D
    
    var identifier: String!
    
    var reminder:Reminders!
    
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
        return "Add rise time here"
    }

    init(coordinate:CLLocationCoordinate2D, identifier:String, reminder:Reminders)
    {
        self.coordinate = coordinate
        self.identifier = identifier
        self.reminder = reminder
    }
    
    required init?(coder decoder: NSCoder)
    {
        let latitude = decoder.decodeDouble(forKey: kISSReminderLatitudeKey)
        let longitude = decoder.decodeDouble(forKey: kISSReminderLongitudeKey)
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
     
        self.identifier = decoder.decodeObject(forKey: kISSReminderIdentifierKey) as! String
        
        // fetch reminder given id
        
        let moc = ISSPagerCoreDataManager.SharedInstance.viewContext
        
        let reminderFetchRequest: NSFetchRequest<Reminders> = Reminders.fetchRequest()
        reminderFetchRequest.fetchBatchSize = 1
        
        let predicate:NSPredicate = NSPredicate(format: "identifier = %@", self.identifier as CVarArg)
        reminderFetchRequest.predicate = predicate
        
        do
        {
            let fetchResult = try moc.fetch(reminderFetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Reminders]
            
            if(fetchResult.count > 0)
            {
                self.reminder = fetchResult[0]
            }
        }
        catch{
            
        }

    }
    func encode(with coder: NSCoder)
    {
        coder.encode(coordinate.latitude, forKey: kISSReminderLatitudeKey)
        coder.encode(coordinate.longitude, forKey: kISSReminderLongitudeKey)
        coder.encode(identifier, forKey: kISSReminderIdentifierKey)

    }
}
