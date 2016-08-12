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
    
    @IBOutlet weak var leavingLabel: UILabel!
    @IBOutlet weak var destinationText: UILabel!
    
    var receivedStudent = Student()
    var receivedString = ""
    let qr = QRCode("0")
    var theBrain = HallPassBrain()
    var id = ""
    var pickerData = [String]()
    let theStudent = Student()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        //look up the student OBJECT from the database so we can alter its properties rather than having a plain string
        //getStudentFromID(id: receivedString) or something like this
        super.viewDidLoad()
        receivedString = String(receivedStudent.id)
        id = String(receivedStudent.id)
        
        theStudent.Trips.append(Trip())
        if let name = defaults.stringForKey("myRoom") {
            myRoomLabel.text = name
        }
        setUpButtons()
        
        //if we don't have a child with this ID, TELL US THAT DON'T CRASH
        
        
        theBrain.dbRef.child(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value!["name"] as? String) != nil {
                self.theStudent.name = snapshot.value!["name"] as! String
                self.theStudent.id = snapshot.value!["id"] as! Int
                self.theStudent.flagged = snapshot.value!["flagged"] as! Bool
                self.theStudent.isScannedOut = snapshot.value!["isScannedOut"] as! Bool
                self.theStudent.numOfTrips = snapshot.value!["numOfTrips"] as! Int
                self.studentNameLabel.text = self.theStudent.name
                //set the flagged button = studentflagged
                
                
                //give us just their most RECENT trip's start time. nothing else matters to our view.
                
                if (self.theStudent.numOfTrips != 0) {
                    self.theBrain.dbRef.child(self.id).child("Trips").child(String(self.theStudent.numOfTrips-1)).observeSingleEventOfType(.Value, withBlock: { secondSnapshot in
                        self.theStudent.Trips[0] = Trip()
                        self.theStudent.Trips[0].arrivalLocation = secondSnapshot.value!["arriveLocation"] as! String
                        
                        print(self.theStudent.Trips[0].arrivalLocation)
                        self.theStudent.Trips[0].timeOfDeparture = secondSnapshot.value!["departTime"] as! Double
                        print("got here")
                        self.theStudent.Trips[0].departLocation = secondSnapshot.value!["departLocation"] as! String
                        print("this went fine")
                        
                        if (self.theStudent.isScannedOut) {
                            //change our view to look like a "scan in" screen...
                            print("in here.")
                            self.leavingLabel.text = "Left:"
                            self.destinationText.text = "Arriving at:"
                            self.destinationLabel.userInteractionEnabled = false
                            self.destinationLabel.text = self.myRoomLabel.text
                            self.myRoomLabel.text = self.theStudent.Trips[0].departLocation
                            print("even got this!")
                        }
                        
                    })
                }
                
                
            } else {
                //TODO: PUSH BACK TO THE OTHER SCREEN?
                print("student doesn't exist!")
            }
            
            
            
        })
        
        
        //Is this student already scanned out (i.e. has an incomplete trip)? If so, scan them IN and change our view accordinly and notify the correct parties.
        
        
        //ask for desintation information, then "submit"
    }
    
    @IBAction func submitButton(sender: UIButton) {
        //make sure the destination is a real place!
        //transverse the room keys database, match it to our room we're looking for, then get the KEY not the value!!!
        let theText = destinationLabel.text
        
        if theText == "" {
            print("please enter a destination!")
            let alert = UIAlertController(title: "Please enter a valid destination.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            theBrain.otherRef.child("roomKeys").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let mySnapshot = snapshot.value! as! NSDictionary
                
                //print(mySnapshot.allKeys[0])
                
                
                
                //scan out... notify OTHER teacher
                if (self.theStudent.isScannedOut) {
                    for i in 0..<mySnapshot.allValues.count {
                        if (mySnapshot.allValues[i] as! String) == self.theStudent.Trips[0].departLocation {
                            //hooray we found our key 🤗
                            print("key found!")
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            if let name = self.defaults.stringForKey("myRoom") {
                                print("posted")
                                appDelegate.mySignal.postNotification(["contents": ["en": "\(self.studentNameLabel.text!) has arrived at \(name)"], "include_player_ids": [mySnapshot.allKeys[i]]])
                            }
                            break
                        }
                    }
                } else {
                    for i in 0..<mySnapshot.allValues.count {
                        if (mySnapshot.allValues[i] as! String) == theText {
                            //hooray we found our key 🤗
                            print("key found!")
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.mySignal.postNotification(["contents": ["en": "\(self.studentNameLabel.text!) is heading to your room."], "include_player_ids": [mySnapshot.allKeys[i]]])
                            break
                        }
                    }
                }
                if (self.theStudent.isScannedOut) {
                    //scan us IN!
                    print("scanning in")
                    if let name = self.defaults.stringForKey("myRoom") {
                        print(self.theStudent.Trips[0].arrivalLocation)
                        if !(self.theStudent.Trips[0].arrivalLocation == "Restroom") {
                            self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips-1)).child("arriveLocation").setValue(name)
                            
                        }
                    }
                    let currentTime = NSDate().timeIntervalSince1970
                    let timeDiff = currentTime - self.theStudent.Trips[0].timeOfDeparture
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips-1)).child("arriveTime").setValue(currentTime)
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips-1)).child("timeElapsed").setValue(timeDiff)
                    self.theBrain.dbRef.child(self.receivedString).child("isScannedOut").setValue(false)
                    let alert = UIAlertController(title: "You have been scanned in.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    //increment the number of trips!
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips)).child("departLocation").setValue(self.myRoomLabel.text)
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips)).child("arriveLocation").setValue(self.destinationLabel.text)
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips)).child("departTime").setValue((NSDate().timeIntervalSince1970))
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips)).child("arriveTime").setValue(0)
                    self.theBrain.dbRef.child(self.receivedString).child("Trips").child(String(self.theStudent.numOfTrips)).child("timeElapsed").setValue(0)
                    self.theBrain.dbRef.child(self.receivedString).child("isScannedOut").setValue(true)
                    self.theBrain.dbRef.child(self.receivedString).child("numOfTrips").setValue(self.theStudent.numOfTrips+1)
                    let alert = UIAlertController(title: "Your hall pass has been approved!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in
                        self.navigationController?.popViewControllerAnimated(true)
                        self.navigationController?.popViewControllerAnimated(true)

                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                
                
            })
        }
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
