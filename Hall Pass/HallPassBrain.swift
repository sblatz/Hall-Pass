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

    init() {
        FIRApp.configure()
        print("here I am!")
        FIRAuth.auth()?.signInWithEmail("sdblatz@gmail.com", password: "family13", completion: { (user:FIRUser?, error: NSError?) in
            if error == nil {
                print(user?.email)
            } else {
                print(error?.description)
            }
        })

        dbRef = FIRDatabase.database().reference().child("students")
    }
    
    
    

    func addStudent (name: String) {
        // 2
        
        //get the count of students in the database, increment by 1 and give this student that ID when GENERATING
        let id = 0
        
        let theSudent = Student()
        theSudent.name = name
       // theSudent.id = id
        theSudent.flagged = false
        
        
        // 3
        let studentRef = dbRef.childByAppendingPath("1")
        
        dbRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value!.objectForKey("name")!)
        })
        
        let nextRef = studentRef.childByAppendingPath("name")
        // 4
        nextRef.setValue(name)
    }
    
    func getStudent (id: Int) {
    
        
    }
    
    func importData (){

    }
}


