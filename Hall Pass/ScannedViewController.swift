//
//  ScannedViewController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit
import QRCode

class ScannedViewController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var myRoomLabel: UILabel!
    @IBOutlet weak var destinationLabel: UITextField!
    
    var receivedString = ""
    let qr = QRCode("0")
    var theBrain = HallPassBrain()
    var id = ""
    var pickerData = [String]()
    
    override func viewDidLoad() {
        //look up the student OBJECT from the database so we can alter its properties rather than having a plain string
        //getStudentFromID(id: receivedString) or something like this
        super.viewDidLoad()
        id = receivedString

        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("myRoom") {
            myRoomLabel.text = name
        }
        setUpButtons()
        
        //if we don't have a child with this ID, TELL US THAT DON'T CRASH

        
        theBrain.dbRef.child(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value!["name"] as? String) != nil {
                let theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                theStudent.flagged = snapshot.value!["flagged"] as! Bool
                
                self.studentNameLabel.text = theStudent.name
            } else {
                //TODO: PUSH BACK TO THE OTHER SCREEN?
                print("student doesn't exist!")
            }
            
            
            
        })
        
        
        //ask for desintation information, then "submit"
    }
    
    @IBAction func submitButton(sender: UIButton) {
        //make sure the destination is a real place!
        //transverse the room keys database, match it to our room we're looking for, then get the KEY not the value!!!
        var theText = destinationLabel.text
        theBrain.otherRef.child("roomKeys").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var mySnapshot = snapshot.value! as! NSDictionary
            
            print(mySnapshot.allKeys[0])
            
            for i in 0..<mySnapshot.allValues.count {
                if mySnapshot.allValues[i] as! String == theText {
                    //hooray we found our key 🤗
                    print("key found!")
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.mySignal.postNotification(["contents": ["en": "\(self.studentNameLabel.text!) is heading to your room."], "include_player_ids": [mySnapshot.allKeys[i]]])
                    break
                }
            }
            
            })
        //mySignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": ["3009e210-3166-11e5-bc1b-db44eb02b120"]])
    }
    
    override func viewDidAppear(animated: Bool) {
        theBrain.otherRef.child("rooms").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            var theCount = 0
            let mySnapshot = snapshot.value! as! NSArray
            
            self.pickerData.removeAll()
            while (mySnapshot[theCount] as? String) != nil {
                self.pickerData.append(mySnapshot[theCount] as! String)
                theCount += 1
                if (theCount >= mySnapshot.count) {
                    break
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
        destinationLabel.inputAssistantItem.leadingBarButtonGroups = []
        destinationLabel.inputAssistantItem.trailingBarButtonGroups = []
        destinationLabel.inputView = picker
        destinationLabel.inputAccessoryView = toolBar
    }
    
    func cancelPicker() {
        destinationLabel.resignFirstResponder()
    }
    
    func donePicker() {
        var textField = UITextField()
        var isAlive = false
        
        
        if destinationLabel.editing {
            textField = destinationLabel
            isAlive = true
        } else {
            isAlive = false
        }
        
        if (isAlive) {
            textField.resignFirstResponder()
            let pickView = textField.inputView as! UIPickerView
            textField.text = pickerData[pickView.selectedRowInComponent(0)]
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
