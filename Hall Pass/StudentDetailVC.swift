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
        
        /*
        brain.dbRef.child("\(receivedStudent.id)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value!["name"] as? String) != nil {
                let theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                theStudent.flagged = snapshot.value!["flagged"] as! Bool
                
                self.studentNameLabel.text = theStudent.name
            } else {
                print("student doesn't exist!")
            }
            
            
            
        })
        */
        
        
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

