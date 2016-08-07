//
//  ManageClassesVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/6/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class ManageClassesVC: UITableViewController {
    
    var classesArray = [String]()
    var brain = HallPassBrain()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        tableView.addGestureRecognizer(longpress)
        
        
        brain.otherRef.child("rooms").observeEventType(.Value, withBlock: { snapshot in
            print("retrieving the data!")
            self.classesArray.removeAll()
            var theCount = 0
            
            if (snapshot.value! as? NSArray != nil) {
                let mySnapshot = snapshot.value! as! NSArray
                while (mySnapshot[theCount] as? String) != nil {
                    self.classesArray.append(mySnapshot[theCount] as! String)
                    theCount += 1
                    if (theCount >= mySnapshot.count) {
                        break
                    }
                }

            }
            
            self.tableView.reloadData()
        })
        
    }
    
    
    @IBAction func addButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "New Class", message: "Please enter the classroom's name:", preferredStyle: .Alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                self.brain.otherRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    self.brain.otherRef.child("rooms").child(String((snapshot.value!["numRooms"] as! Int))).setValue(field.text)
                    self.brain.otherRef.child("numRooms").setValue((snapshot.value!["numRooms"] as! Int)+1)
                    self.classesArray.append(field.text!)
                    //self.tableView.reloadData()
                })
                //NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: "userEmail")
                //NSUserDefaults.standardUserDefaults().synchronize()
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Classroom"
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func addButton() {
        
    }
    
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesArray.count
    }
    
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
   
        cell?.textLabel?.text = classesArray[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            //brain.otherRef.child("rooms").child(String(indexPath.row)).removeValue()
        
            print(classesArray)
        
            for i in indexPath.row..<classesArray.count-1 {
                //move the rest of the items up!
                classesArray[i] = classesArray[i+1]
            }
            
            classesArray.removeLast()
            
            print(classesArray)

            

            
            brain.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
                var numOfRooms = snapshot.value!["numRooms"] as! Int
                for i in 0..<self.classesArray.count {
                    self.brain.otherRef.child("rooms").child(String(i)).setValue(self.classesArray[i])
                }
                
                self.brain.otherRef.child("numRooms").setValue(numOfRooms-1)

                self.brain.otherRef.child("rooms").child(String(self.classesArray.count)).removeValue()

                })
            
        }
    }
    
    
    func changeOrderInDatabase() {
       
            brain.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                var theCount = 0
                for i in 0..<self.classesArray.count {
                    //loop through the array, adding each element into our database.
                    self.brain.otherRef.child("rooms").child(String(theCount)).setValue(self.classesArray[i])
                    theCount += 1
                }

            })
            
        

        
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell)
                
                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            My.cellIsAnimating = false
                            if My.cellNeedToShow {
                                My.cellNeedToShow = false
                                UIView.animateWithDuration(0.25, animations: { () -> Void in
                                    cell.alpha = 1
                                })
                            } else {
                                cell.hidden = true
                            }
                        }
                })
            }
            
        case UIGestureRecognizerState.Changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    classesArray.insert(classesArray.removeAtIndex(Path.initialIndexPath!.row), atIndex: indexPath!.row)
                    tableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.hidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransformIdentity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            Path.initialIndexPath = nil
                            My.cellSnapshot!.removeFromSuperview()
                            My.cellSnapshot = nil
                            self.changeOrderInDatabase()
                        }
                })
            }
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    
    
}