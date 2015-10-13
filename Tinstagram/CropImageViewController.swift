//
//  CropImageViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 13/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class CropImageViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var cropImageDisplay: UIImageView!
    
    var imageReceived: UIImage!
    
    
    // MARK: - Actions
    
    @IBAction func cropButton(sender: UIButton) {
        
    }
    
    
    @IBAction func UndoCropButton(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropImageDisplay.image = imageReceived
        
    }
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var imageEffectVC: ImageEffectViewController = segue.destinationViewController as! ImageEffectViewController
        imageEffectVC.imageReceived = cropImageDisplay.image!
        
    }


}
