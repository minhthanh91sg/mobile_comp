//
//  CameraViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 7/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    
    /* Displays custom Camera control */
    @IBOutlet var cameraControlView: UIView! = nil
    
    /* Displays picked image */
    @IBOutlet weak var pickedImageDisplay: UIImageView!
    
    var imagePicker: UIImagePickerController? = UIImagePickerController()
    
    // MARK: - Actions
    
    /* Shows an Alert option to pick the image from Gallery or Camera */
    @IBAction func chooseImageButton(sender: AnyObject) {
        var alert: UIAlertController = UIAlertController(title: "Choose Image From:", message: nil, preferredStyle: .ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style:UIAlertActionStyle.Default, handler: {action in self.selectCamera()} )
        
        var galleryAction = UIAlertAction(title: "Gallery", style:UIAlertActionStyle.Default, handler: {action in self.selectGallery()} )
        
        var cancelAction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    // MARK: - Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageDisplay.contentMode = .ScaleAspectFit
            pickedImageDisplay.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
            effectsNavButton.enabled = true
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Voids
    
    /* Picks an Image from Camera*/
    func selectCamera(){
        println("Camera Selected")
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker!.cameraCaptureMode = .Photo
            imagePicker!.showsCameraControls = false
            
            NSBundle.mainBundle().loadNibNamed("CameraControlView", owner: self, options: nil)
            cameraControlView.frame = imagePicker!.cameraOverlayView!.frame
            imagePicker?.cameraOverlayView = cameraControlView
            cameraControlView = nil
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
        
        else {
            noCameraAlarm()
        }

        
        
    }
    
    /* Picks an Image from Gallery */
    func selectGallery(){
        println("Gallery Selected")
        self.imagePicker!.allowsEditing = false
        self.imagePicker!.sourceType = .SavedPhotosAlbum
        self.presentViewController(imagePicker!, animated: true, completion: nil)
        
    }
    
    /* Shows an alert message when Camera is not detected */
    func noCameraAlarm(){
        let alertVC = UIAlertController(title: "No Camera Detected", message: "This device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker!.delegate = self
        effectsNavButton.enabled = false

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Camera Control Actions
    
   
    @IBAction func shutterButton(sender: UIButton) {
        imagePicker!.takePicture()
    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func flashButton(sender: UIButton) {
        if (imagePicker!.cameraFlashMode == .Auto){
            imagePicker!.cameraFlashMode = .Off
            sender.setTitle("Off", forState: UIControlState.Normal)
            println("Flash Off")
            
        }
        else if (imagePicker!.cameraFlashMode == .Off){
            imagePicker!.cameraFlashMode = .On
            sender.setTitle("On", forState: UIControlState.Normal)
            println("Flash On")
        }
        else {
            imagePicker!.cameraFlashMode = .Auto
            sender.setTitle("Auto", forState: UIControlState.Normal)
            println("Flash Auto")
        }

    }
        /* Select Camera Device .Front or .Rear */
        
    @IBAction func selectCameraDevice(sender: UIButton) {
        
        if (imagePicker?.cameraDevice == .Front){
            self.imagePicker?.cameraDevice = .Rear

        }
        else {
            self.imagePicker?.cameraDevice = .Front
        }
    }
    

    /* effects Navigation Button is enabled only when the user picks an new image. Segue with EffectsViewController*/
    @IBOutlet weak var effectsNavButton: UIBarButtonItem!
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var imageEffectVC: ImageEffectViewController = segue.destinationViewController as! ImageEffectViewController
        imageEffectVC.imageReceived = pickedImageDisplay.image!
        pickedImageDisplay.image = nil
        effectsNavButton.enabled = false
    }
    
    
    
    /*/ Unwind segue

    @IBAction func unwindToHomeVC(segue: UIStoryboardSegue){
        if (segue.sourceViewController .isKindOfClass(ShareImageViewController)){
            effectsNavButton.enabled = false
            println("I came from Edit Image")
        }
    }

    */

}
