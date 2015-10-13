//
//  ShareImageViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 8/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ShareImageViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var editedImageDisplay: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    /* Image received from ImageEffectViewController */
    var imageReceived: UIImage!
    
    /* Limit of characters for comment */
    let textFieldCharLimit = 144
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CImageEffectViewController
        editedImageDisplay.image = imageReceived
        
        //textField delegate
        textField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    /* Sends photo to parse backend */
    @IBAction func shareButton(sender: AnyObject) {
        let imageData = UIImageJPEGRepresentation(self.imageReceived, 0.5) //image compression
        let imageFile = PFFile(data: imageData)
        var currentUser = PFUser.currentUser()?.objectId
        var userImage = PFObject(className: "Image")
        var likes = 0
        var comments = 0
        var description = textField.text
        
        userImage["image"] = imageFile
        userImage["userId"] = currentUser
        userImage["likes"] = likes
        userImage["comments"] = comments
        userImage["description"] = description
        userImage.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("object was saved")
                
            } else {
                // There was a problem, check error.description
                println("Object not saved")
            }
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        editedImageDisplay.image = nil
        description = nil
        
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewControllerAnimated(true)

        
        //UIImageWriteToSavedPhotosAlbum(self.imageReceived, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
        
    }

    
    // MARK: Delegates
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("Allow editing")
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        println("User is editing text")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("User done editing text")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Enter was pressed")
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var length = count(textField.text) + count(string)
        
        if (length > textFieldCharLimit) {
            return false
        }
        else {return true}
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
   

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
