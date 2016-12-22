//
//  Cells.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import Foundation
import MapKit

class MapTableViewCell:UITableViewCell
{
    @IBOutlet var mapview:MKMapView!
}

class RemindersDetailMainCell:UITableViewCell
{
    @IBOutlet var label:UILabel!
    @IBOutlet var textfield:UITextField!
}
