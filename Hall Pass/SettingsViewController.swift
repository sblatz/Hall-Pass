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

    var theBrain = HallPassBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theBrain.otherRef.child("rooms").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            var theCount = 0
            let mySnapshot = snapshot.value! as! NSArray
            
            print(mySnapshot[0])
            
            while (mySnapshot[theCount] as? String) != nil {
                self.pickerData.append(mySnapshot[theCount] as! String)
                theCount += 1
                if (theCount >= mySnapshot.count) {
                    break
                }
            }
            
           
            
        })
        
        setUpButtons()
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
            
            theBrain.mySignal.IdsAvailable({(userId, pushToken) in
                 //print(userId)
                self.theBrain.otherRef.child("roomKeys").child(userId).setValue(textField.text)
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