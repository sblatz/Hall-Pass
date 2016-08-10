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
    var timeElapsed = 0.0
    var timeOfDeparture = 0.0
    var timeOfArrival = 0.0
}

class Student {
    var name = ""
    var id = -1
    var flagged = false
    var Trips = [Trip]()
    var numOfTrips = 0
    var isScannedOut = false
    var gradeLevel = 0
}



class HallPassBrain {
    var dbRef: FIRDatabaseReference
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var theData: String {
        return delegate.importedData
    }
    
    var otherRef: FIRDatabaseReference
        
    init() {
        if (!delegate.hasBeenConfigured) {
            delegate.hasBeenConfigured = true
            FIRApp.configure()
            print("configured")
            //let token = FIRInstanceID.instanceID().token()!
            //print(token)
            FIRAuth.auth()?.signInWithEmail("sdblatz@gmail.com", password: "family13", completion: { (user:FIRUser?, error: NSError?) in
                if error == nil {
                    print(user?.email)
                } else {
                    print(error?.description)
                }
            })
            
            
        }
        
        dbRef = FIRDatabase.database().reference().child("schools").child("0").child("students")
        otherRef = FIRDatabase.database().reference().child("schools").child("0")
        
        
        
    }
    

    
    
    
    func addStudent (name: String) {
        
        //get the current number of students from the database
        
        self.dbRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            //print("Inside closure...")
            //print(self.numStudents)
           // self.dbRef.child("\(self.numStudents)").child("name").setValue(name)
            
            
            
        })
        
        
    }
    
    func addUserId (userID: String) {
        
        //add the key to the database with an "unassigned" room corresponding to it.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("myRoom") {
            self.otherRef.child("roomKeys").child(userID).setValue(name)
        } else {
            self.otherRef.child("roomKeys").child(userID).setValue("Unassigned")
        }
    }
    
    func addStudent (studentArray: [Student]) {
        self.otherRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            var numOfStudents = snapshot.value!["numStudents"] as! Int
            
            for i in 0..<studentArray.count {
                //loop through the array, adding each element into our database.
                self.dbRef.child("\(numOfStudents)").child("name").setValue(studentArray[i].name)
                self.dbRef.child("\(numOfStudents)").child("flagged").setValue(false)
                self.dbRef.child("\(numOfStudents)").child("id").setValue(numOfStudents)
                self.dbRef.child("\(numOfStudents)").child("isScannedOut").setValue(false)
                self.dbRef.child("\(numOfStudents)").child("numOfTrips").setValue(0)
                self.dbRef.child("\(numOfStudents)").child("grade").setValue(studentArray[i].gradeLevel)
                numOfStudents += 1
            }
            
            //when we're done looping, now update the database to store the correct number of students.
            
            self.otherRef.child("numStudents").setValue(numOfStudents)
        })
        
    }
    
    func getStudent (id: Int) {
        
    }
    
    
    func retreiveAllStudents() {
        dbRef.observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value!.objectForKey("name")!)
        })
        
    }
    
    
    func getNumberOfStudents(completionHandler: (Int) -> ()) {
        dbRef.observeSingleEventOfType(.Value, withBlock: { (snapShot) in
            print("incrementing")
            self.dbRef.child("numStudents").setValue((snapShot.value!["numStudents"] as! Int) + 1)
        })
        
        dbRef.observeSingleEventOfType(.Value, withBlock: { (snapShot) in
            print("returning")
            completionHandler(snapShot.value!["numStudents"] as! Int)
            
        })
        
    }
    
    
    
    func importData(){
        //parse the data, upload it to firebase.
        let lineOfText = delegate.importedData.componentsSeparatedByString("\n")
        var studentArray = [Student]()
        
        for i in 0..<lineOfText.count {
            let parsedData = lineOfText[i].componentsSeparatedByString("\t")
            var theStudent = Student()
            var fullName = parsedData[0] + " " + parsedData[1]
            //print(parsedData[2])
            var gradeLevel = parsedData[2].stringByReplacingOccurrencesOfString("\r", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            gradeLevel = gradeLevel.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var realGrade = Int(gradeLevel)!
            fullName = fullName.stringByReplacingOccurrencesOfString("\r", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            fullName = fullName.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            theStudent.name = fullName
            theStudent.gradeLevel = realGrade
            print(theStudent.name)
            studentArray.append(theStudent)
            
        }
        
        addStudent(studentArray)
        
        
    }
}


