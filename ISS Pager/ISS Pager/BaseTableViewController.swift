//
//  BaseTableViewController.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Configuration
    
    func configureCell(_ cell: UITableViewCell, forReminder reminder: ISSReminder) {
       // configure cell here, Nick
        
        cell.textLabel?.text = reminder.name
        cell.detailTextLabel?.text = "Earliest arrival: \(reminder.arrivalTimes[0].riseTime.humanReadableDate)"
        
    }

}
