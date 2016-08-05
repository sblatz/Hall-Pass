//
//  StudentNavigationController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/5/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import Foundation
import UIKit


class StudentNavigationController: UINavigationController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // get a reference to the second view controller
        let secondViewController = segue.destinationViewController as! ScannedViewController
        
        // set a variable in the second view controller with the String to pass
        secondViewController.receivedString = sender as! String
    }
    
    
}