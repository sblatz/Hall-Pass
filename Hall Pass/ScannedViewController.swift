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
    let qr = QRCode("Sawyer Blatz")
    
    override func viewDidLoad() {
        //look up the student OBJECT from the database so we can alter its properties rather than having a plain string
        //getStudentFromID(id: receivedString) or something like this
        super.viewDidLoad()
        studentNameLabel.text = receivedString

       // imageView.image = qr!.image!
     
        //ask for desintation information, then "submit"
    }
    

}
