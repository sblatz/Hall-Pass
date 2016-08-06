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

    // create a sound ID, in this case its the tweet sound.
    
   
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
//        let settings: UIUserNotificationSettings =
//            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//        application.registerUserNotificationSettings(settings)
//        application.registerForRemoteNotifications()

        var theBrain = HallPassBrain()

        
        
        var mySignal = OneSignal.init(launchOptions: launchOptions, appId: "d9dac52b-78d3-49a4-93d6-42a47c591536", handleNotification: { (result) in
            
            // This block gets called when the user reacts to a notification received
            let alert = UIAlertController(title: result.0, message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        })
        
        mySignal.IdsAvailable({(userId, pushToken) in
            NSLog("UserId:%@", userId)
            theBrain.addUserId(userId)
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
                let alert = UIAlertController(title: "Data Imported!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        
        
        
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

