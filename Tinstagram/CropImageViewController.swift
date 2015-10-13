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
    var context: CIContext!
    
    
    // MARK: - Actions
    
    @IBAction func cropButton(sender: UIButton) {
        let imageSize = CGSize(width: 400, height: 400)
        var croppedImage: UIImage = cropImageDisplay.image!
        var beginImage: CIImage = CIImage(image: croppedImage)
        let cropIm = beginImage.imageByCroppingToRect(CGRect(origin: CGPoint(x: 100, y: 100), size: imageSize))
        context = CIContext(options: nil)
        let renderedImage = context.createCGImage(cropIm, fromRect: cropIm.extent())
        let newImage = UIImage(CGImage: renderedImage)
        cropImageDisplay.image = newImage
        
        
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
