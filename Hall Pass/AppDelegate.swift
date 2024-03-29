//
//  AppDelegate.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var importedData = ""
    var hasBeenConfigured = false
    var mySignal = OneSignal()
    // create a sound ID, in this case its the tweet sound.
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        var brain = HallPassBrain()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(dayChange),
            name: NSCalendarDayChangedNotification,
            object: nil)
        mySignal = OneSignal.init(launchOptions: launchOptions, appId: "d9dac52b-78d3-49a4-93d6-42a47c591536", handleNotification: { (result) in
            // This block gets called when the user reacts to a notification received
            
            
            var theMessage = result.0
            print(result.1[1])
            
            if theMessage.containsString("join your school") {
                let alert = UIAlertController(title: result.0, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    
                    print("allowed")
                    
                    brain.otherRef.child("roomKeys").observeSingleEventOfType(.Value, withBlock: { snapshot in
                        let mySnapshot = snapshot.value! as! NSDictionary
                        for i in 0..<mySnapshot.allValues.count {
                            print(mySnapshot.allValues[i] as! String)
                            if (mySnapshot.allValues[i] as! String) == "Pending Approval" {
                                //hooray we found our key 🤗
                                print("key found!")
                                var userID = mySnapshot.allKeys[i] as! String
                                brain.otherRef.child("roomKeys").child(userID).setValue("Approved")
                                
                                self.mySignal.postNotification(["contents": ["en": "You have been approved! You can now sign in."], "include_player_ids": [mySnapshot.allKeys[i]]])

                               
                                break
                            }
                        }
                        
                    })
                    
                }))
                alert.addAction(UIAlertAction(title: "Deny", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    brain.otherRef.child("roomKeys").observeSingleEventOfType(.Value, withBlock: { snapshot in
                        let mySnapshot = snapshot.value! as! NSDictionary
                        for i in 0..<mySnapshot.allValues.count {
                            if (mySnapshot.allValues[i] as! String) == "Pending Approval" {
                                //hooray we found our key 🤗
                                print("key found!")
                                var userID = mySnapshot.allKeys[i] as! String
                                brain.otherRef.child("roomKeys").child(userID).setValue("Denied")
                                
                                break
                            }
                        }
                        
                    })
                }))
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                
            } else if (theMessage.containsString("has arrived")){
                let alert = UIAlertController(title: result.0, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                //UIApplication.sharedApplication().cancelAllLocalNotifications()
                print("I'm here 🤗")
            } else {
                let alert = UIAlertController(title: result.0, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                print("😂")
            }
            
        })
        
        mySignal.IdsAvailable({(userId, pushToken) in
            NSLog("UserId:%@", userId)
            //self.theBrain.addUserId(userId)
            if (pushToken != nil) {
                NSLog("pushToken:%@", pushToken)
            }
        })
        
        
        
        
        
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //url contains a URL to the file your app shall open
        
        do {
            importedData = try String(contentsOfURL: url)
            let alert = UIAlertController(title: "Data Imported", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Sweet!", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        } catch {
            print(error)
        }
        
        
        var theBrain = HallPassBrain()
        print("Data imported!")
        theBrain.importData()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        
        
        print(userInfo)
        /*
         let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
         alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
         self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
         */
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //save the current date so we can compare it
        
    }
    
    func dayChange() {
        //with a new day we set all our students to scanned IN and we set numOfTrips = 0, ONLY if we're the admin
        
        var myBrain = HallPassBrain()
        print("day change")
        myBrain.otherRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var studentCount = snapshot.value!["numStudents"] as! Int
            var adminId = snapshot.value!["admin"] as! String
            print(studentCount)
            myBrain.dbRef.observeSingleEventOfType(.Value, withBlock: { mySnapshot in
                self.mySignal.IdsAvailable({(userId, pushToken) in
                    //print(userId)
                    if userId == adminId {
                        for i in 0..<studentCount {
                            //if the student exists, do it, otherwise up our studentCount and skip it
                            if mySnapshot.hasChild(String(i)) {
                                myBrain.dbRef.child(String(i)).child("tripsToday").setValue(0)
                                myBrain.dbRef.child(String(i)).child("isScannedOut").setValue(false)
                            } else {
                                studentCount += 1
                            }
                            
                        }
                        
                    }
                })
                
            })
        })
        
    }
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

