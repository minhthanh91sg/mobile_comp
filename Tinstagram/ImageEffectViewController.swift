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
    
    //let context = CIContext(options: nil)
    
    var context: CIContext!
    
    var filter: CIFilter!
    
    var beginImage: CIImage!

    @IBOutlet weak var brightnessAmount: UISlider!
    
    @IBOutlet weak var contrastAmount: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CameraViewController
        effectImageDisplay.image = imageReceived
        beginImage = CIImage(image: imageReceived)
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions 
    
    
    @IBAction func normalFilterButton(sender: AnyObject) {
        effectImageDisplay.image = imageReceived
    }
    
    /* Filter 1 - Sepia */
    @IBAction func filterOneButton(sender: AnyObject) {
        
        filter = CIFilter(name: "CISepiaTone")
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(0.6, forKey: kCIInputIntensityKey)
        
        let filteredImage = filter.outputImage
        
        effectImageDisplay.image = applyFilter(filteredImage)
        
    }
    
    /* Filter 2 - Fade */
    @IBAction func filterTwoButton(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectFade")
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setDefaults()

        let filteredImage = filter.outputImage
        
        effectImageDisplay.image = applyFilter(filteredImage)
    }
    
    
    /* Filter 3 - Black-and-White  */
    @IBAction func filterThreeButton(sender: AnyObject) {
        filter = CIFilter(name: "CIPhotoEffectNoir")
        println(filter)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setDefaults()
        
        let filteredImage = filter.outputImage
        
        effectImageDisplay.image = applyFilter(filteredImage)
        
    }
    
    @IBAction func changeBrightnessValue(sender: UISlider) {
        
    }
    
    
    @IBAction func changeContrastValue(sender: UISlider) {
        
    }

    // MARK: - Navigation
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var shareImageVC: ShareImageViewController = segue.destinationViewController as! ShareImageViewController
        shareImageVC.imageReceived = effectImageDisplay.image!
        effectImageDisplay.image = nil
        
    }

    
    // MARK: - Image functions
    
    func applyFilter (filteredImg: CIImage) -> UIImage {
        context = CIContext(options: nil)
        let renderedImage = context.createCGImage(filteredImg, fromRect: filteredImg.extent())
        
        let newImage = UIImage(CGImage: renderedImage, scale: self.imageReceived.scale, orientation: self.imageReceived.imageOrientation)
        
        return newImage!
        
    }
    
}
