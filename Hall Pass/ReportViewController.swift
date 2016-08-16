//
//  ReportViewController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import UIKit
import Foundation

class ReportViewController: UITableViewController {
    var reports = ["Roaming students", "Students out more than 3 times", "Students out for longer than 4 minutes", "Flagged students"]
    
    
    override func viewDidLoad() {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(reports[indexPath.row])
        self.navigationController?.performSegueWithIdentifier("toDetailReport", sender: reports[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = reports[indexPath.row]
        return cell!
    }
    
}