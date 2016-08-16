//
//  DetailReportVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/8/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
class DetailReportVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var theBrain = HallPassBrain()
    var reportType = ""
    var reportedStudents = [Student]()
    override func viewDidLoad() {
        
        switch(reportType) {
        case "Roaming students":
            tableView.rowHeight = 110
            
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
        case "Students out more than 3 times":
            tableView.rowHeight = 44
            
            self.navigationItem.title = "Students out 4+ times"
            theBrain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                let theStudent = Student()
                if snapshot.value!["tripsToday"] as! Int > 3 {
                    theStudent.name = snapshot.value!["name"] as! String
                    theStudent.tripsToday = snapshot.value!["tripsToday"] as! Int
                    self.reportedStudents.append(theStudent)
                    
                }
                if (self.reportedStudents.count > 1) {
                    for i in 1..<self.reportedStudents.count {
                        if (self.reportedStudents[i].tripsToday > self.reportedStudents[i-1].tripsToday) {
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
        case "Students out for longer than 4 minutes":
            tableView.rowHeight = 44
            self.navigationItem.title = "Students out for 4+ minutes"
            theBrain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                let theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.tripsToday = snapshot.value!["tripsToday"] as! Int
                theStudent.numOfTrips = snapshot.value!["numOfTrips"] as! Int
                theStudent.id = snapshot.value!["id"] as! Int
                //get all the trips from today
                self.theBrain.dbRef.child(String(theStudent.id)).child("Trips").observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    for i in 0..<theStudent.tripsToday {
                        
                        var newTrip = Trip()
                        if snapshot.hasChild("arriveLocation") {
                            newTrip.arrivalLocation = snapshot.value!["arriveLocation"] as! String
                        }
                        if snapshot.hasChild("arriveTime"){
                            newTrip.timeOfArrival = snapshot.value!["arriveTime"] as! Double
                        }
                        if snapshot.hasChild("departLocation"){
                            newTrip.departLocation = snapshot.value!["departLocation"] as! String
                        }
                        if snapshot.hasChild("departTime"){
                            newTrip.timeOfDeparture = snapshot.value!["departTime"] as! Double
                        }
                        if snapshot.hasChild("timeElapsed"){
                            newTrip.timeElapsed = snapshot.value!["timeElapsed"] as! Double
                        }
                        var myDate = NSDate.init(timeIntervalSince1970: newTrip.timeOfDeparture)
                        if NSCalendar.currentCalendar().isDateInToday(myDate)
                        {
                            
                            //date crap 😒
                            
                            if newTrip.timeElapsed == 0 {
                                //we have to calculate it ourselves 🙄
                                var diff = NSDate().timeIntervalSince1970 - newTrip.timeOfDeparture
                                
                                //print(diff)
                                newTrip.timeElapsed = diff
                            }
                            
                            
                            
                            if newTrip.timeElapsed > 240 {
                                theStudent.Trips.append(newTrip)
                                
                            }
                            
                        }
                    }
                    
                    if theStudent.Trips.count > 0 {
                        
                        //make sure we're not already on the list.
                        
                        if self.reportedStudents.count == 0 {
                            print(theStudent.name)
                            self.reportedStudents.append(theStudent)
                        }
                        for i in 0..<self.reportedStudents.count {
                            if self.reportedStudents[i].name == theStudent.name {
                                
                            } else {
                                print(theStudent.name)
                                self.reportedStudents.append(theStudent)
                            }
                        }
                        
                        
                    }
                    self.tableView.reloadData()
                    
                })
            })
            break
        case "Flagged students":
            self.navigationItem.title = "Flagged Students"
            theBrain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                var theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                theStudent.flagged = snapshot.value!["flagged"] as! Bool
                
                if theStudent.flagged {
                    self.reportedStudents.append(theStudent)
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
    
    @IBAction func shareButton(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            let defaults = NSUserDefaults.standardUserDefaults()
            if let name = defaults.stringForKey("email") {
                mail.setToRecipients([name])
                
            }
            var listOfStudents = ""
            for i in 0..<reportedStudents.count {
                if i == 0 {
                    listOfStudents = reportedStudents[i].name
                } else {
                    listOfStudents = listOfStudents.stringByAppendingString(", \(reportedStudents[i].name)")
                    
                }
            }
            mail.setMessageBody("<p><b>\(reportType)</b></p><p>\(listOfStudents)</p>", isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if reportType == "Roaming students" {
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
            
            
        } else if reportType == "Students out more than 3 times" {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TripCell
            
            cell.dateLabel.text = reportedStudents[indexPath.row].name
            cell.timeElapsedLabel.text = "\(reportedStudents[indexPath.row].tripsToday) trips today"
            cell.arriveTimeLabel.text = ""
            cell.arriveRoomLabel.text = ""
            cell.dateLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            return cell
        } else if reportType == "Students out for longer than 4 minutes" {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TripCell
            //cell.dateLabel.text = "ARE YOU THERE?"
            cell.dateLabel.text = reportedStudents[indexPath.row].name
            cell.timeElapsedLabel.text = ""
            cell.arriveTimeLabel.text = ""
            cell.arriveRoomLabel.text = ""
            cell.dateLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TripCell
            //cell.dateLabel.text = "ARE YOU THERE?"
            cell.dateLabel.text = reportedStudents[indexPath.row].name
            cell.timeElapsedLabel.text = ""
            cell.arriveTimeLabel.text = ""
            cell.arriveRoomLabel.text = ""
            cell.dateLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            return cell
        }
        return UITableViewCell()
    }
}