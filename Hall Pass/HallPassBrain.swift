//
//  HallPassBrain.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation

import Firebase
import FirebaseDatabase

class Trip {
    var departLocation = ""
    var arrivalLocation = ""
    var timeElapsed = 0
    var timeOfDeparture = 0
    var timeOfArrival = 0
}

class Student {
    var name = ""
   // var id = -1
    var flagged = false
    var Trips = [Trip]()
    
}



class HallPassBrain {
    var dbRef: FIRDatabaseReference
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var theData: String {
        return delegate.importedData
    }
    
    
    init() {
        if (!delegate.hasBeenConfigured) {
            delegate.hasBeenConfigured = true
            FIRApp.configure()
            print("configuring")
            FIRAuth.auth()?.signInWithEmail("sdblatz@gmail.com", password: "family13", completion: { (user:FIRUser?, error: NSError?) in
                if error == nil {
                    print(user?.email)
                } else {
                    print(error?.description)
                }
            })
        }
       
        dbRef = FIRDatabase.database().reference().child("schools").child("0").child("students")
    }
    
    
    

    func addStudent (name: String) {
        
        //get the current number of students from the database
        
        
        loadShows() {
            self.dbRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                
                print(name)
                
                var numOfStudents = snapshot.value!["numStudents"] as! Int
                
                print(numOfStudents)
                
                self.dbRef.child("\(numOfStudents)").child("name").setValue(name)
                
                numOfStudents += 1
                
                self.dbRef.child("numStudents").setValue(numOfStudents)
                
                
            })

            print("Background Fetch Complete")
        }
        
        
       //print(dbRef.child("numStudents").value
        
        //retreiveAllStudents()
        
        /*
        let studentRef = self.dbRef.child("\(numOfStudents)")
        let nextRef = studentRef.child("name")
        nextRef.setValue(name)
        dbRef.child("numStudents").setValue(numOfStudents)
        numOfStudents += 1
        */
        
    }
    
    func getStudent (id: Int) {
        
    }
    
    func retreiveAllStudents() {
        
        
        dbRef.observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value!.objectForKey("name")!)
        })

    }
    
    func loadShows(completionHandler: (() -> Void)!) {
        //....
        //DO IT
        //....
        completionHandler()
    }
    
    func importData(){
            //parse the data, upload it to firebase.
        let lineOfText = delegate.importedData.componentsSeparatedByString("\n")
        
        for i in 0..<lineOfText.count-1 {
            let parsedData = lineOfText[i].componentsSeparatedByString("\t")
            
            var fullName = parsedData[0] + " " + parsedData[1]
            
            fullName = fullName.stringByReplacingOccurrencesOfString("\r", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            fullName = fullName.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            print(fullName)
            addStudent(fullName)
        }
    }
}


