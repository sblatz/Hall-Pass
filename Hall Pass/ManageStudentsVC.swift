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
            self.studentArray.append(theStudent)
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
    
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
        
    }




}