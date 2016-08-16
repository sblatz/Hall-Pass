//
//  SettingsViewController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var roomNameInput: UITextField!
    var pickerData = [String]()
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var settingsOptions = [String]()
    var studentArray = [Student]()
    @IBOutlet weak var table: UITableView!
    
    var theBrain = HallPassBrain()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:0.94, green:0.93, blue:0.96, alpha:1.0)
        settingsOptions.append("Sign Out")
        table.delegate = self
        table.dataSource = self
        var view = UIView()
        view.backgroundColor = UIColor(red:0.94, green:0.93, blue:0.96, alpha:1.0)
        table.tableFooterView = view
        table.alwaysBounceVertical = false
        
        
        
        //make sign out red text and centered
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("myRoom") {
            roomNameInput.text = name
        }
        
        theBrain.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            self.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                //print(userId)
                //var userID = "05d65db9-3bee-4d4b-88c6-7e374b638eb8"
                if (userId == (snapshot.value!["admin"] as! String)) {
                    self.settingsOptions.insert("Export Student IDs", atIndex: 0)
                    self.settingsOptions.insert("Manage Students", atIndex: 0)
                    self.settingsOptions.insert("Manage Classrooms", atIndex: 0)
                }
                
                if self.settingsOptions.count == 1 {
                    self.table.separatorStyle = .None
                }
                self.table.reloadData()
            })

            //if i'm the admin, make the manage students and classes buttons visible, otherwise, keep them hidden!
            
            

        })
        
        setUpButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        theBrain.otherRef.child("rooms").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            var theCount = 0
            if snapshot.value! as? NSArray != nil {
                let mySnapshot = snapshot.value! as! NSArray
                self.pickerData.removeAll()
                while (mySnapshot[theCount] as? String) != nil {
                    self.pickerData.append(mySnapshot[theCount] as! String)
                    theCount += 1
                    if (theCount >= mySnapshot.count) {
                        break
                    }
                }
            }
            
            
        })
    }
    
    
    func setUpButtons() {
        var picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        picker.backgroundColor = .whiteColor()
        
        //picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.userInteractionEnabled = true
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPicker")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        roomNameInput.inputAssistantItem.leadingBarButtonGroups = []
        roomNameInput.inputAssistantItem.trailingBarButtonGroups = []
        roomNameInput.inputView = picker
        roomNameInput.inputAccessoryView = toolBar
        
        
        
        
    }
    
    func cancelPicker() {
        roomNameInput.resignFirstResponder()
        //self.table.frame.size.height = CGFloat(44 * self.settingsOptions.count)
        //table.reloadData()
    }
    
    func donePicker() {
        var textField = UITextField()
        var isAlive = false
        
        
        if roomNameInput.editing {
            textField = roomNameInput
            isAlive = true
        } else {
            isAlive = false
        }
        
        if (isAlive) {
            textField.resignFirstResponder()
            let pickView = textField.inputView as! UIPickerView
            textField.text = pickerData[pickView.selectedRowInComponent(0)]
            //send this TO THE CLOUD! assign us to this room 😂
            
            theBrain.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                //print(userId)
                self.theBrain.otherRef.child("roomKeys").child(userId).setValue(textField.text)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(textField.text, forKey: "myRoom")
            })
        }
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = settingsOptions[indexPath.row]
        if (cell?.textLabel?.text == "Sign Out") {
            //make us red and center us!

            cell?.textLabel?.textAlignment = .Center
            cell?.textLabel?.textColor = UIColor.redColor()
        } else {
            cell?.textLabel?.textAlignment = .Left
            cell?.textLabel?.textColor = UIColor.blackColor()

        }

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (!roomNameInput.editing) {
            let ourCell = tableView.cellForRowAtIndexPath(indexPath)
            
            if ourCell?.textLabel!.text == "Manage Classrooms" {
                performSegueWithIdentifier("toClasses", sender: nil)
            } else if ourCell?.textLabel!.text == "Manage Students" {
                performSegueWithIdentifier("toStudents", sender: nil)

            } else if ourCell?.textLabel!.text == "Export Student IDs" {
                composeMail()
            } else {
                //sign out!
                let defaults = NSUserDefaults.standardUserDefaults()
                
                theBrain.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                    //print(userId)
                    self.theBrain.otherRef.child("roomKeys").child(userId).setValue("Approved")
                })
                defaults.setObject("", forKey: "email")
                defaults.setObject("", forKey: "password")
                self.tabBarController!.performSegueWithIdentifier("toLogin", sender: nil)
                
            }

        }
        
        table.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func composeMail(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            let defaults = NSUserDefaults.standardUserDefaults()
            if let name = defaults.stringForKey("email") {
                mail.setToRecipients([name])
                
            }
            
            var listOfStudents = ""

            theBrain.dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                let theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                listOfStudents = listOfStudents.stringByAppendingString("<p>\(theStudent.id): \(theStudent.name)</p>")
                mail.setMessageBody("<p><b>Student IDs</b></p><p>\(listOfStudents)</p>", isHTML: true)

            })
            
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                //put your code which should be executed with a delay here
                self.presentViewController(mail, animated: true, completion: nil)

            }
            
            
            

          
        } else {
            // show failure alert
        }

    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
}