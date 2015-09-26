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
    @IBInspectable var flashButtonColor: UIColor = UIColor.grayColor()

    
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
            
            let cameraControlBar = UIView(frame: CGRectMake(0, self.view.frame.width,self.view.frame.width , self.view.frame.height - self.view.frame.width))
            cameraControlBar.backgroundColor = UIColor.blackColor()
            cameraControlBar.alpha = 0
            bringSubviewToCameraOverlayView(overlayView, customView: cameraControlBar)
            
           
            
            
            /* Custom Camera Shutter button */
            let shutterButton = UIView(frame: CGRectMake(self.view.frame.width/2 - 40, self.view.frame.height - 80, 80, 80))
            shutterButton.layer.cornerRadius = 40
            shutterButton.userInteractionEnabled = true
            shutterButton.backgroundColor = shutterButtonColor
            bringSubviewToCameraOverlayView(overlayView, customView: shutterButton)

            
            let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleSnapTap:"))
            recognizer.delegate = self
            shutterButton.addGestureRecognizer(recognizer)
            
            /* Custom Camera Cancel button */
            
            let cancelButton = UIView(frame: CGRectMake(10, 10, 44, 44))
            cancelButton.userInteractionEnabled = true
            cancelButton.backgroundColor = cancelButtonColor
            bringSubviewToCameraOverlayView(overlayView, customView: cancelButton)
            
            let cancelRecognizer = UITapGestureRecognizer(target: self, action: "handleCancelTap:")
            cancelRecognizer.delegate = self
            cancelButton.addGestureRecognizer(cancelRecognizer)
            
            /* Custom Flash button */
            let flashButton = UIView(frame: CGRectMake(10, self.view.frame.height - 46, 44, 44))
            flashButton.userInteractionEnabled = true
            flashButton.backgroundColor = flashButtonColor
            bringSubviewToCameraOverlayView(overlayView, customView: flashButton)
            
            let flashRecognizer = UITapGestureRecognizer(target: self, action: "handleFlashTap:")
            flashRecognizer.delegate = self
            flashButton.addGestureRecognizer(flashRecognizer)
            
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
    
    func handleFlashTap(recognizer: UITapGestureRecognizer){
        println("Flash")
        
        if (imagePicker.cameraFlashMode == .Off){
            imagePicker.cameraFlashMode = .On
            cancelButtonColor = UIColor.yellowColor()
            println("Flash On")
            
        }
        else {
            imagePicker.cameraFlashMode = .Off
            cancelButtonColor = UIColor.grayColor()
            println("Flash Off")
        }
        
        
    }
    
    func bringSubviewToCameraOverlayView (overlayView: UIView, customView: UIView) {
        overlayView.addSubview(customView)
        overlayView.bringSubviewToFront(customView)
    }
    
    // Puts the taken photo in the image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageView.contentMode = .ScaleAspectFit
            pickedImageView.image = pickedImage
            
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.5)
            let imageFile = PFFile(name: "image.jpg", data: imageData)
            
            var userImage = PFObject(className: "Image")
            var userId = PFUser.currentUser()?.objectId
            println(userId)
            userImage["userId"] = userId
            userImage["image"] = imageFile
            
            userImage.saveInBackground()
            
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
        
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    

}
