//
//  CameraViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 16/09/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit
@IBDesignable


class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    @IBInspectable var shutterButtonColor: UIColor = UIColor.blueColor()
    @IBInspectable var cancelButtonColor: UIColor = UIColor.grayColor()

    
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
    }

    @IBOutlet weak var pickedImageView: UIImageView!
    
    @IBAction func OpenCamera(sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            
            
            
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = false
            
            
            let overlayView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            overlayView.backgroundColor = UIColor.clearColor()
            
            /* Custom Camera Shutter button */
            let shutterButton = UIView(frame: CGRectMake(self.view.frame.width/2 - 40, self.view.frame.height - 80, 80, 80))
            shutterButton.layer.cornerRadius = 40
            shutterButton.userInteractionEnabled = true
            shutterButton.backgroundColor = shutterButtonColor
            println(shutterButton)
            overlayView.addSubview(shutterButton)
            overlayView.bringSubviewToFront(shutterButton)
            
            
            let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleSnapTap:"))
            recognizer.delegate = self
            shutterButton.addGestureRecognizer(recognizer)
            
            /* Custom Camera Cancel button */
            
            let cancelButton = UIView(frame: CGRectMake(10, 10, 44, 44))
            cancelButton.userInteractionEnabled = true
            cancelButton.backgroundColor = cancelButtonColor
            println(cancelButton)
            overlayView.addSubview(cancelButton)
            overlayView.bringSubviewToFront(cancelButton)
            
            let cancelRecognizer = UITapGestureRecognizer(target: self, action: "handleCancelTap:")
            cancelRecognizer.delegate = self
            cancelButton.addGestureRecognizer(cancelRecognizer)
            
            imagePicker.cameraOverlayView = overlayView
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            println("camera not available")
            //put an alert alert message here ?
        }
    }
    
    func handleSnapTap(recognizer: UITapGestureRecognizer) {
        println("Take picture")
        imagePicker.takePicture()
        
    }
    
    func handleCancelTap(recognizer: UITapGestureRecognizer){
        println("Cancel")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    // Puts the taken photo in the image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageView.contentMode = .ScaleAspectFit
            pickedImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
        

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
