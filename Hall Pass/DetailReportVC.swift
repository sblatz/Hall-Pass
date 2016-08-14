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
        tableView.rowHeight = 110
        
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
                    var trips = snapshot.value!["Trips"] as! NSArray
                    var recentTrip = trips[theStudent.numOfTrips-1] as! NSDictionary
                    var theTrip = Trip()
                    theTrip.arrivalLocation = recentTrip.allValues[0] as! String
                    theTrip.timeOfArrival = recentTrip.allValues[1] as! Double
                    theTrip.departLocation = recentTrip.allValues[2] as! String
                    theTrip.timeOfDeparture = recentTrip.allValues[3] as! Double
                    theStudent.Trips.append(theTrip)
                    
                    
                    //copy their most recent trip too.
                    self.reportedStudents.append(theStudent)
                    
                    
                }
                
                //sort the students by LONGEST out of room...
                if (self.reportedStudents.count > 1) {
                    for i in 1..<self.reportedStudents.count {
                        var timeElapsed = NSDate().timeIntervalSince1970 - self.reportedStudents[i].Trips[0].timeOfDeparture
                        var timeElapsed2 = NSDate().timeIntervalSince1970 - self.reportedStudents[i-1].Trips[0].timeOfDeparture
                        
                        if (timeElapsed > timeElapsed2) {
                            //switch us.
                            var tempStudent = self.reportedStudents[i-1]
                            self.reportedStudents[i-1] = self.reportedStudents[i]
                            self.reportedStudents[i] = tempStudent
                        }
                    }
                }
                
                self.tableView.reloadData()
            })
            
            break
        default:
            break
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        reportedStudents.removeAll()
        viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(reportedStudents.count)
        return reportedStudents.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TripCell
        
        cell.dateLabel.text = reportedStudents[indexPath.row].name
        
        var timeElapsed = NSDate().timeIntervalSince1970 - reportedStudents[indexPath.row].Trips[0].timeOfDeparture
        
        
        
        var minutes = Int(floor(timeElapsed/60))
        var seconds = Int((Int((timeElapsed)) - minutes * 60))
        
        if timeElapsed > 240 {
            print("cell \(indexPath.row) is red")
            cell.timeElapsedLabel.textColor = UIColor.redColor()
        } else {
            cell.timeElapsedLabel.textColor = UIColor.blackColor()
            
        }
        
        cell.timeElapsedLabel.text = "\(minutes)m \(seconds)s"
        cell.departRoomLabel.text = reportedStudents[indexPath.row].Trips[0].departLocation
        cell.arriveRoomLabel.text = reportedStudents[indexPath.row].Trips[0].arrivalLocation
        var date = NSDate.init(timeIntervalSince1970: reportedStudents[indexPath.row].Trips[0].timeOfDeparture)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let theDate = dateFormatter.stringFromDate(date)
        
        cell.departTimeLabel.text = theDate
        cell.arriveTimeLabel.text = ""
        return cell
        
        //cell?.textLabel!.text = reportedStudents[indexPath.row].name
        
        
    }
    
}