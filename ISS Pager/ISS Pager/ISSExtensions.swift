//
//  ISSExtensions.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/21/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import Foundation
import UIKit

let kSavedItemsKey = "ISSPagerSavedReminders"

extension String {
    var URLEscapedString: String {
        
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)!
        
    }
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}

extension Notification.Name // the different notifications we'll want to listen to
{
    static let onISSWithinUserRange = Notification.Name("onISSWithinUserRange")
    static let onISSWithinReminderRange = Notification.Name("onISSWithinReminderRange")
}

extension Date
{
    var humanReadableDate:String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US") // for now. Useful for localization later 
        
        return dateFormatter.string(from: self)
        
    }
        /// Returns the amount of years from another date
        func years(from date: Date) -> Int {
            return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
        }
        /// Returns the amount of months from another date
        func months(from date: Date) -> Int {
            return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
        }
        /// Returns the amount of weeks from another date
        func weeks(from date: Date) -> Int {
            return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
        }
        /// Returns the amount of days from another date
        func days(from date: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
        }
        /// Returns the amount of hours from another date
        func hours(from date: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
        }
        /// Returns the amount of minutes from another date
        func minutes(from date: Date) -> Int {
            return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
        }
        /// Returns the amount of seconds from another date
        func seconds(from date: Date) -> Int {
            return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
        }
}
