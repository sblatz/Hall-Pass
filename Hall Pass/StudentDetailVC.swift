//
//  StudentDetailVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/5/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class StudentDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var receivedStudent = Student()
    var brain = HallPassBrain()
    
    @IBOutlet weak var studentNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var gradeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receivedStudent.Trips = receivedStudent.Trips.reverse()
        studentNameLabel.text = receivedStudent.name
        gradeLabel.text = "Grade \(receivedStudent.gradeLevel)"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 110
        receivedStudent.Trips.removeAll()
        
        brain.dbRef.child(String(receivedStudent.id)).observeSingleEventOfType(.Value, withBlock: {snapshot in
            self.receivedStudent.flagged = snapshot.value!["flagged"] as! Bool
            if (self.receivedStudent.flagged) {
                self.studentNameLabel.textColor = UIColor.redColor()
                
                let item = self.navigationItem.rightBarButtonItem
                item?.title = "Unflag"
            }
            
            
            
        })
        if receivedStudent.Trips.count != 0 {
            brain.dbRef.child(String(receivedStudent.id)).child("Trips").observeEventType(.ChildAdded, withBlock: { snapshot in
                var newTrip = Trip()
                
                newTrip.arrivalLocation = snapshot.value!["arriveLocation"] as! String
                newTrip.timeOfArrival = snapshot.value!["arriveTime"] as! Double
                newTrip.departLocation = snapshot.value!["departLocation"] as! String
                newTrip.timeOfDeparture = snapshot.value!["departTime"] as! Double
                newTrip.timeElapsed = snapshot.value!["timeElapsed"] as! Double
                
                
                
                self.receivedStudent.Trips.insert(newTrip, atIndex: 0)
                
                
                self.tableView.reloadData()
                
            })
        }
        
        //myTable.reloadData()
        
    }
    
    
    
    
    @IBAction func flagStudent(sender: AnyObject) {
        receivedStudent.flagged = !receivedStudent.flagged
        brain.dbRef.child(String(receivedStudent.id)).child("flagged").setValue(receivedStudent.flagged)
        if (receivedStudent.flagged) {
            let item = self.navigationItem.rightBarButtonItem
            item?.title = "Unflag"
            studentNameLabel.textColor = UIColor.redColor()
        } else {
            let item = self.navigationItem.rightBarButtonItem
            item?.title = "Flag"
            studentNameLabel.textColor = UIColor.blackColor()
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedStudent.Trips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TripCell
        
        //date crap 😒
        var date = NSDate.init(timeIntervalSince1970: receivedStudent.Trips[indexPath.row].timeOfDeparture)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute], fromDate: date)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let theDate = dateFormatter.stringFromDate(date)
        
        var minutes = Int(floor(receivedStudent.Trips[indexPath.row].timeElapsed/60))
        var seconds = Int((Int((receivedStudent.Trips[indexPath.row].timeElapsed)) - minutes * 60))
        if receivedStudent.Trips[indexPath.row].timeElapsed > 240 {
            cell.timeElapsedLabel.textColor = UIColor.redColor()
        }
        var year = String(components.year)
        year = year.substringFromIndex((year.startIndex.advancedBy(2)))
        
        var otherDate = NSDate.init(timeIntervalSince1970: receivedStudent.Trips[indexPath.row].timeOfArrival)
        let arrivalString = dateFormatter.stringFromDate(otherDate)
        
        if (receivedStudent.Trips[indexPath.row].timeOfArrival == 0) {
            print("Student is in transit...")
            cell.arriveTimeLabel.text = "N/A"
            cell.timeElapsedLabel.text = "N/A"
            //cell.arriveRoomLabel.text = "In Transit"
            
            
        } else {
            cell.arriveTimeLabel.text = arrivalString
            cell.timeElapsedLabel.text = "~ \(minutes)m \(seconds)s"
            
        }
        cell.arriveRoomLabel.text = receivedStudent.Trips[indexPath.row].arrivalLocation
        cell.dateLabel.text = "\(components.month)-\(components.day)-\(year)"
        cell.departRoomLabel.text = receivedStudent.Trips[indexPath.row].departLocation
        cell.departTimeLabel.text = theDate
        //cell.arriveTimeLabel.text = arrivalString
        
        /*
         
         if cell == nil {
         cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
         }
         
         
         
         var date = NSDate.init(timeIntervalSince1970: receivedStudent.Trips[indexPath.row].timeOfDeparture)
         let calendar = NSCalendar.currentCalendar()
         let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute], fromDate: date)
         
         let dateFormatter = NSDateFormatter()
         dateFormatter.dateFormat = "h:mm a"
         let theDate = dateFormatter.stringFromDate(date)
         
         var minutes = Int(floor(receivedStudent.Trips[indexPath.row].timeElapsed/60))
         var seconds = Int((Int((receivedStudent.Trips[indexPath.row].timeElapsed)) - minutes * 60))
         var year = String(components.year)
         year = year.substringFromIndex((year.startIndex.advancedBy(2)))
         let dateString = "\(components.month)-\(components.month)-\(year)\t\t\t\(theDate)\t\t\t\(minutes)m \(seconds)s"
         cell!.textLabel?.text = dateString
         cell?.textLabel!.font = cell?.textLabel!.font.fontWithSize(19)
         var fontName = cell?.textLabel!.font.fontName.componentsSeparatedByString("-").first
         cell?.textLabel!.font  = UIFont(name: "\(fontName!)-Semibold", size: (cell?.textLabel!.font.pointSize)!)
         
         
         
         cell!.detailTextLabel?.text = "\(receivedStudent.Trips[indexPath.row].departLocation) -> \(receivedStudent.Trips[indexPath.row].arrivalLocation)"
         cell?.detailTextLabel!.font = cell?.detailTextLabel!.font.fontWithSize(16)
         fontName = cell?.detailTextLabel!.font.fontName.componentsSeparatedByString("-").first
         
         cell?.detailTextLabel!.font  = UIFont(name: "\(fontName!)-Light", size: (cell?.detailTextLabel!.font.pointSize)!)
         
         */
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        print(indexPath.row)
    }
    
}

