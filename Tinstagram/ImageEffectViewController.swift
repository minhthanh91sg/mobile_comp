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
    
    /* Filter 1 */
    @IBAction func filterOneButton(sender: AnyObject) {
        // create an Image to filter
        let inputImage = CIImage(image: effectImageDisplay.image)
        
        // create a random color to pass the filter
        
        let randomColor = [kCIInputAngleKey: (Double(arc4random_uniform(314)) / 100)]
        
        // Apply filter to the image
        let filteredImage = inputImage.imageByApplyingFilter("CIHueAdjust", withInputParameters: randomColor)
        
        //render the filtered image
        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        
        // Reflect the change back in the interface
        effectImageDisplay.image = UIImage(CGImage: renderedImage)

    }
    
    /* Filter 2 */
    @IBAction func filterTwoButton(sender: AnyObject) {
    }
    
    /* Filter 3 */
    @IBAction func filterThreeButton(sender: AnyObject) {
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var shareImageVC: ShareImageViewController = segue.destinationViewController as! ShareImageViewController
        shareImageVC.imageReceived = effectImageDisplay.image!
        
    }
    
}
