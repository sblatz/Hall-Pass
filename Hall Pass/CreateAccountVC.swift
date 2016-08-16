//
//  CreateAccountVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/15/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountVC: UIViewController {
    
    @IBOutlet weak var schoolCodeButton: UILabel!
    var theBrain = HallPassBrain()
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var numSchools = 0
    override func viewDidLoad() {
        schoolCodeButton.text = ""
        
        theBrain.outRef.child("numSchools").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            self.numSchools = snapshot.value! as! Int
            self.schoolCodeButton.text = "School Code: \(String(snapshot.value! as! Int))"
            self.defaults.setObject(snapshot.value! as! Int, forKey: "schoolCode")
            self.theBrain = HallPassBrain()
        })
        
    }
    
    @IBAction func createAdmin(sender: AnyObject) {
        if emailField.text! == "" || (!(emailField.text?.containsString("@"))!) {
            let alert = UIAlertController(title: "Please enter an email address.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if passwordField.text! == "" {
            let alert = UIAlertController(title: "Please enter a password.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            delegate.mySignal.IdsAvailable({(userId, pushToken) in
                self.theBrain.outRef.child(String(self.numSchools)).child("admin").setValue(userId)
                self.theBrain.outRef.child("numSchools").setValue(self.numSchools+1)
                self.theBrain.otherRef.child("roomKeys").child(userId).setValue("Approved")
                self.theBrain.otherRef.child("numStudents").setValue(0)
                self.theBrain.otherRef.child("numRooms").setValue(0)
                let alert = UIAlertController(title: "Your school has been created!", message: "Please write down your school code, as you will need it to log in.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Hooray!", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            })
        }
        
        //your account has been created, please log in now! pop view
    }
}