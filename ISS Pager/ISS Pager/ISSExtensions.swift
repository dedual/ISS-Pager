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
}
