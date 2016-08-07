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
import Firebase

extension ManageStudentsVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension ManageStudentsVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class ManageStudentsVC: UITableViewController {

    var brain = HallPassBrain()
    var studentArray = [Student]()
    var filteredStudents = [Student]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        brain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            let theStudent = Student()
            theStudent.name = snapshot.value!["name"] as! String
            theStudent.id = snapshot.value!["id"] as! Int
            theStudent.flagged = snapshot.value!["flagged"] as! Bool
            theStudent.isScannedOut = snapshot.value!["isScannedOut"] as! Bool
            theStudent.numOfTrips = snapshot.value!["numOfTrips"] as! Int
            for i in 0..<theStudent.numOfTrips {
                theStudent.Trips.append(Trip())
                var array = snapshot.value!["Trips"] as! NSArray
                var element = array[i] as! NSDictionary
                theStudent.Trips[i].arrivalLocation = element.allValues[0] as! String
                theStudent.Trips[i].timeOfArrival = element.allValues[1] as! Double
                theStudent.Trips[i].departLocation = element.allValues[2] as! String
                theStudent.Trips[i].timeOfDeparture = element.allValues[3] as! Double
                theStudent.Trips[i].timeElapsed = element.allValues[4] as! Double
                
            }
            self.studentArray.append(theStudent)
            self.tableView.reloadData()
        })
        
        
      
        
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            //brain.otherRef.child("rooms").child(String(indexPath.row)).removeValue()
            
            for i in indexPath.row..<studentArray.count-1 {
                //move the rest of the items up!
                studentArray[i] = studentArray[i+1]
            }
            studentArray.removeLast()
            
            brain.otherRef.child("students").child(String(studentArray.count)).removeValue()
            
            //update the database....

            //TODO: Deep copy the trips!
            
            brain.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                var numOfStudents = snapshot.value!["numStudents"] as! Int
                
                for i in 0..<self.studentArray.count {
                    //loop through the array, adding each element into our database.
                    self.brain.dbRef.child("\(i)").child("name").setValue(self.studentArray[i].name)
                    self.brain.dbRef.child("\(i)").child("flagged").setValue(self.studentArray[i].flagged)
                    self.brain.dbRef.child("\(i)").child("id").setValue(i)
                    self.brain.dbRef.child("\(i)").child("isScannedOut").setValue(self.studentArray[i].isScannedOut)
                    self.brain.dbRef.child("\(i)").child("numOfTrips").setValue(self.studentArray[i].numOfTrips)
                    //loop through their trips....
                    
                    for j in 0..<self.studentArray[i].Trips.count {
                        self.brain.dbRef.child("\(i)").child("Trips").child(String(j)).child("arriveLocation").setValue(self.studentArray[i].Trips[j].arrivalLocation)
                        self.brain.dbRef.child("\(i)").child("Trips").child(String(j)).child("departLocation").setValue(self.studentArray[i].Trips[j].departLocation)
                        self.brain.dbRef.child("\(i)").child("Trips").child(String(j)).child("arriveTime").setValue(self.studentArray[i].Trips[j].timeOfArrival)
                        self.brain.dbRef.child("\(i)").child("Trips").child(String(j)).child("departTime").setValue(self.studentArray[i].Trips[j].timeOfDeparture)
                        self.brain.dbRef.child("\(i)").child("Trips").child(String(j)).child("timeElapsed").setValue(self.studentArray[i].Trips[j].timeElapsed)
                    }
                }
                
                //when we're done looping, now update the database to store the correct number of students.
                
                
                self.brain.otherRef.child("numStudents").setValue(numOfStudents-1)
            })

            
            self.tableView.reloadData()
            
        }
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredStudents = studentArray.filter { student in
            return student.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addStudent(sender: UIBarButtonItem) {
        
        //give a dialog box to create a new student
        
        //brain.addStudent("Bob")
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredStudents.count
        }
        return studentArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if searchController.active && searchController.searchBar.text != "" {
            cell?.textLabel?.text = filteredStudents[indexPath.row].name
        } else {
            cell?.textLabel?.text = studentArray[indexPath.row].name
        }
        

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //grab the student they selected, and let's push to a new view where they can edit information about that student
        var studentToSend = Student()
        if searchController.active && searchController.searchBar.text != "" {
            studentToSend = filteredStudents[indexPath.row]
        } else {
            studentToSend = studentArray[indexPath.row]
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        self.navigationController?.performSegueWithIdentifier("toStudentDetail", sender: studentToSend)

    }
    
    
  



}