//
//  ManageStudentsVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ManageStudentsVC: UITableViewController {

    var brain = HallPassBrain()
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        brain.dbRef.observeEventType(.Value, withBlock: { snapshot in
            
           
            self.tableView.reloadData()
        })
    
    }
    
    
    @IBAction func addStudent(sender: UIBarButtonItem) {
        brain.addStudent("Bob")
    }
}