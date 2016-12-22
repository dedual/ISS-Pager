//
//  ResultsTableViewController.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit

class ResultsTableViewController: BaseTableViewController {

    var filteredReminders:[ISSReminder] = [ISSReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredReminders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "basicCellReminder")
        
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "basicCellReminder")
            cell?.selectionStyle = .none
        }
        
        
        let reminder = filteredReminders[indexPath.row]
        configureCell(cell!, forReminder: reminder)
        
        return cell!
    }

}
