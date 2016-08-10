//
//  ViewController.swift
//  Hall Pass
//
//  Created by Sawyer Blatz on 8/3/16.
//  Copyright © 2016 Sawyer Blatz. All rights reserved.
//

import UIKit
import AVFoundation
import QRCode
import Firebase

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let defaults = NSUserDefaults.standardUserDefaults()
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    
    var nextController: ScannedViewController?
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var hasScanned = false
    //var theBrain = HallPassBrain()
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var theCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCameraView()
        
        
        if let email = defaults.stringForKey("email") {
            if let password = defaults.stringForKey("password") {
                if (!delegate.hasBeenConfigured) {
                    delegate.hasBeenConfigured = true
                    FIRApp.configure()
                    print("configured")
                }
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user:FIRUser?, error: NSError?) in
                        if error == nil {
                            print(user?.email)
                        } else {
                            print("in here...")
                            self.tabBarController?.performSegueWithIdentifier("toLogin", sender: nil)
                            print(error?.description)
                        }
                    })
                    
                
            } else {
                self.tabBarController?.performSegueWithIdentifier("toLogin", sender: nil)
            }
        } else {
            self.tabBarController?.performSegueWithIdentifier("toLogin", sender: nil)

        }

        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        hasScanned = false
        
    }
    
    
    
    @IBAction func swapCamera(sender: AnyObject) {
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if (theCamera.position == AVCaptureDevicePosition.Back) {
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.Front {
                    theCamera = device
                    print("changing to front!")
                    createCameraView()
                    break
                }
            }
        } else {
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.Back {
                    theCamera = device
                    createCameraView()
                    break
                }
            }
        }
        
    }
    
    
    
    func createCameraView() {
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: theCamera)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            /*
             // Initialize QR Code Frame to highlight the QR code
             qrCodeFrameView = UIView()
             
             if let qrCodeFrameView = qrCodeFrameView {
             qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
             qrCodeFrameView.layer.borderWidth = 2
             view.addSubview(qrCodeFrameView)
             view.bringSubviewToFront(qrCodeFrameView)
             }
             */
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // qrCodeFrameView?.removeFromSuperview()
        captureSession?.startRunning()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        captureSession?.stopRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            //let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            //qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //push segue
                if Int(metadataObj.stringValue) != nil {
                    let theBrain = HallPassBrain()
                    theBrain.dbRef.child(metadataObj.stringValue).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if (snapshot.value!["name"] as? String) != nil {
                            if (!self.hasScanned) {
                                self.navigationController?.performSegueWithIdentifier("toIDView", sender: metadataObj.stringValue)
                            }
                            self.hasScanned = true
                        } else {
                            let alert = UIAlertController(title: "Student not in database.", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    })
                    
                    
                    
                } else {
                    print("not scanning this because it's not a number...")
                    let alert = UIAlertController(title: "Invalid QR code", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
        }
    }
}

