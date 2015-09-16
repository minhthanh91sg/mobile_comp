//
//  CameraViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 16/09/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
    }

    @IBOutlet weak var pickedImageView: UIImageView!
    
    @IBAction func OpenCamera(sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            
            imagePicker.sourceType = .Camera
            imagePicker.editing = true
            //imagePicker.showsCameraControls = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            println("camera not available")
            //put an alert alert message here ?
        }
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
