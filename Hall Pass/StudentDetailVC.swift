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
    @IBOutlet weak var flaggedSwitch: UISwitch!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        receivedStudent.Trips = receivedStudent.Trips.reverse()
        studentNameLabel.text = receivedStudent.name
        flaggedSwitch.on = receivedStudent.flagged
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        
        //myTable.reloadData()

    }
    
    
    
    
    @IBAction func flaggedSwitchChanged(sender: UISwitch) {
        
        print(flaggedSwitch.on)
        
        receivedStudent.flagged = !receivedStudent.flagged
        
        brain.dbRef.child(String(receivedStudent.id)).child("isFlagged").setValue(receivedStudent.flagged)
        
        
        //update our database to reflect the flagged change!!
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedStudent.Trips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }

        var date = NSDate.init(timeIntervalSince1970: receivedStudent.Trips[indexPath.row].timeOfDeparture)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute], fromDate: date)
        let dateString = "\(components.month)-\(components.month)-\(components.year)   \(components.hour):\(components.minute)"
        cell!.textLabel?.text = dateString
        cell?.textLabel!.font = cell?.textLabel!.font.fontWithSize(19)
        var fontName = cell?.textLabel!.font.fontName.componentsSeparatedByString("-").first
        cell?.textLabel!.font  = UIFont(name: "\(fontName!)-Semibold", size: (cell?.textLabel!.font.pointSize)!)

        
        
        cell!.detailTextLabel?.text = "\(receivedStudent.Trips[indexPath.row].departLocation) -> \(receivedStudent.Trips[indexPath.row].arrivalLocation)"
        cell?.detailTextLabel!.font = cell?.detailTextLabel!.font.fontWithSize(16)
        fontName = cell?.detailTextLabel!.font.fontName.componentsSeparatedByString("-").first
        
        cell?.detailTextLabel!.font  = UIFont(name: "\(fontName!)-Light", size: (cell?.detailTextLabel!.font.pointSize)!)
        return cell!
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        print(indexPath.row)
    }
    
}

