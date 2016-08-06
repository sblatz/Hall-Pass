//
//  StudentDetailVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/5/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class StudentDetailVC: UIViewController, UITableViewDelegate {
    var receivedStudent = Student()
    var brain = HallPassBrain()
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var flaggedSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        studentNameLabel.text = receivedStudent.name
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        flaggedSwitch.on = receivedStudent.flagged
        tableView.delegate = self

        //get all of their trips here!
        
        
        //tableView.dataSource = self
    }
    
    
    
    
    @IBAction func flaggedSwitchChanged(sender: UISwitch) {
        
        print(flaggedSwitch.on)
        
        //update our database to reflect the flagged change!!
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        return cell!
    }
    
}

