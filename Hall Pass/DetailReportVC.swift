//
//  DetailReportVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/8/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class DetailReportVC: UITableViewController {
    
    var theBrain = HallPassBrain()
    var reportType = ""
    var reportedStudents = [Student]()
    override func viewDidLoad() {
        switch(reportType) {
        case "Roaming Students":
            //fill our array with all the students scanned OUT
            self.navigationItem.title = "Roaming Students"
            theBrain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                let theStudent = Student()
                if (snapshot.value!["isScannedOut"] as! Bool) {
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                theStudent.flagged = snapshot.value!["flagged"] as! Bool
                theStudent.isScannedOut = snapshot.value!["isScannedOut"] as! Bool
                theStudent.numOfTrips = snapshot.value!["numOfTrips"] as! Int
                theStudent.gradeLevel = snapshot.value!["grade"] as! Int
                self.reportedStudents.append(theStudent)
                }
                self.tableView.reloadData()
            })
            
            break
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportedStudents.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel!.text = reportedStudents[indexPath.row].name
        
        
        return cell!
    }
    
}