//
//  ISSExtensions.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/21/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var URLEscapedString: String {
        
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)!
        
    }
    var UTF8EncodedData: Data {
        return self.data(using: String.Encoding.utf8)!
    }
}
