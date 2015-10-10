//
//  ImageEffectViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 7/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ImageEffectViewController: UIViewController {

    // MARK: - Properties
    
    /* Shows the recent picked image to apply a filter effect */
    
    @IBOutlet weak var effectImageDisplay: UIImageView!
    
    /* Image received from CameraViewController */
    var imageReceived: UIImage!
    
    //Create a place to render the filtered image
    let context = CIContext(options: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CameraViewController
        effectImageDisplay.image = imageReceived
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions 
    
    
    @IBAction func normalFilterButton(sender: AnyObject) {
        effectImageDisplay.image = imageReceived
    }
    
    /* Filter 1 - ToneCurve */
    @IBAction func filterOneButton(sender: AnyObject) {
        // create an Image to filter
        let inputImageOne = CIImage(image: effectImageDisplay.image)
        
        // Apply filter to the image
        let filteredImage = inputImageOne.imageByApplyingFilter("CILinearToSRGBToneCurve", withInputParameters: nil)
        
        //render the filtered image
        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        
        // Reflect the change back in the interface
        effectImageDisplay.image = UIImage(CGImage: renderedImage)

    }
    
    /* Filter 2 - Fade */
    @IBAction func filterTwoButton(sender: AnyObject) {
        let inputImageTwo = CIImage(image: imageReceived)
        let filteredImageTwo = inputImageTwo.imageByApplyingFilter("CIPhotoEffectFade", withInputParameters: nil)
        let renderedImageTwo = context.createCGImage(filteredImageTwo, fromRect: filteredImageTwo.extent())
        effectImageDisplay.image = UIImage(CGImage: renderedImageTwo)
        
    }
    
    
    /* Filter 3 - Black-and-White */
    @IBAction func filterThreeButton(sender: AnyObject) {
        let inputImageThree = CIImage(image: imageReceived)
        let filteredImageThree = inputImageThree.imageByApplyingFilter("CIPhotoEffectNoir", withInputParameters: nil)
        let renderedImageThree = context.createCGImage(filteredImageThree, fromRect: filteredImageThree.extent())
        effectImageDisplay.image = UIImage(CGImage: renderedImageThree)
        
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var shareImageVC: ShareImageViewController = segue.destinationViewController as! ShareImageViewController
        shareImageVC.imageReceived = effectImageDisplay.image!
        
    }
    
}
