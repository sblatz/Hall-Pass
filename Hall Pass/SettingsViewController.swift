//
//  SettingsViewController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var roomNameInput: UITextField!
    var pickerData = [String]()
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var manageClasses: UIButton!
    @IBOutlet weak var manageStudents: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var theBrain = HallPassBrain()
    override func viewDidLoad() {
        super.viewDidLoad()
        manageClasses.hidden = true
        manageStudents.hidden = true
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("myRoom") {
            roomNameInput.text = name
        }
        
        theBrain.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            self.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                //print(userId)
                var userID = "05d65db9-3bee-4d4b-88c6-7e374b638eb8"
                if (userID == (snapshot.value!["admin"] as! String)) {
                    self.manageClasses.hidden = false
                    self.manageStudents.hidden = false
                }
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
    
    @IBAction func exportData(sender: UIButton) {
        
        
       
    }
    
    @IBAction func signOut(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setObject("", forKey: "email")
        defaults.setObject("", forKey: "password")
        self.tabBarController!.performSegueWithIdentifier("toLogin", sender: nil)
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