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
        
        // 1
        brain.dbRef.observeEventType(.Value, withBlock: { snapshot in
            
            // 2
            var newItems = [Student]()
            
            // 3
            for item in snapshot.children {
                
                // 4
                let groceryItem = Student(snapshot: item as! FIRDataSnapshot)
                newItems.append(groceryItem)
            }
            
            // 5
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    @IBAction func addStudent(sender: UIBarButtonItem) {
        brain.addStudent("Bob")
    }
}