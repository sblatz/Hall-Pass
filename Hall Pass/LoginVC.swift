//
//  LoginVC.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/8/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var schoolCodeField: UITextField!
    let defaults = NSUserDefaults.standardUserDefaults()
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        if let email = defaults.stringForKey("email") {
            if let password = defaults.stringForKey("password") {
                if (!delegate.hasBeenConfigured) {
                    delegate.hasBeenConfigured = true
                    FIRApp.configure()
                    print("configured")
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user:FIRUser?, error: NSError?) in
                        if error == nil {
                            print(user?.email)
                            self.performSegueWithIdentifier("toTabView", sender: nil)
                        } else {
                            print(error?.description)
                        }
                    })
                    
                }
            }
        }
        
        emailField.keyboardType = UIKeyboardType.EmailAddress
        schoolCodeField.keyboardType = UIKeyboardType.NumberPad
    }
    
    
    
    @IBAction func createAccount(sender: UIButton) {
        if (!delegate.hasBeenConfigured) {
            delegate.hasBeenConfigured = true
            FIRApp.configure()
            print("configured")
            
        }
        var dbRef = FIRDatabase.database().reference().child("schools").child("\(schoolCodeField.text!)")
        
        let ref = FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: nil)
        //if school code is empty, ask them to fill it, etc.
        
        //request permission from admin of school code X
        //if they're still waiting for the admin to respond, give a popup saying they must get permission from the school's admin first.
        var theBrain = HallPassBrain()
        dbRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var admin = snapshot.value!["admin"] as! String
            self.delegate.mySignal.postNotification(["contents": ["en": "\(self.emailField.text!) would like to join your school."], "include_player_ids": [admin]])
            self.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                //print(userId)
                theBrain.otherRef.child("roomKeys").child(userId).setValue("Pending Approval")
            })

            
        })
        
        
        
        
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        if (!delegate.hasBeenConfigured) {
            delegate.hasBeenConfigured = true
            FIRApp.configure()
            print("configured")
            
        }
        var dbRef = FIRDatabase.database().reference().child("schools").child("\(schoolCodeField.text!)")
        dbRef.child("roomKeys").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.delegate.mySignal.IdsAvailable({(userId, pushToken) in
                if (snapshot.value!["\(userId)"] as! String) == "Approved" {
                    FIRAuth.auth()?.signInWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user:FIRUser?, error: NSError?) in
                        if error == nil {
                            print(user?.email)
                            dbRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                                print("signed in! store this...")
                                self.defaults.setObject(self.emailField.text!, forKey: "email")
                                self.defaults.setObject(self.passwordField.text!, forKey: "password")
                                self.performSegueWithIdentifier("toTabView", sender: nil)
                            })
                            
                        } else {
                            print(error?.description)
                        }
                    })

                }
            })
        
        })

            }
}