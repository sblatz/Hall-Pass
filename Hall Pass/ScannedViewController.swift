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

class ScannedViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    
    var receivedString = ""
    let qr = QRCode("0")
    var brain = HallPassBrain()
    var id = ""
    
    override func viewDidLoad() {
        //look up the student OBJECT from the database so we can alter its properties rather than having a plain string
        //getStudentFromID(id: receivedString) or something like this
        super.viewDidLoad()
        id = receivedString

        //if we don't have a child with this ID, TELL US THAT DON'T CRASH
        
        brain.dbRef.child(id).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value!["name"] as? String) != nil {
                let theStudent = Student()
                theStudent.name = snapshot.value!["name"] as! String
                theStudent.id = snapshot.value!["id"] as! Int
                theStudent.flagged = snapshot.value!["flagged"] as! Bool
                
                self.studentNameLabel.text = theStudent.name
            } else {
                print("student doesn't exist!")
            }
            
            
            
        })
        
        
        //get the student from the database
        
        
        //studentNameLabel.text = receivedString

       // imageView.image = qr!.image!
     
        //ask for desintation information, then "submit"
    }
    

}
