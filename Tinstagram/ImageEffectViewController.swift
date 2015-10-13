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
    
    var brightness: Float = 0.0
    var contrast: Float = 0.0

    @IBOutlet weak var brightnessAmount: UISlider!
    
    @IBOutlet weak var contrastAmount: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CameraViewController
        effectImageDisplay.image = imageReceived
        beginImage = CIImage(image: imageReceived)
        brightness = 0.9
        contrast = 0.9
        
        
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
        
        effectImageDisplay.image = applyFilter("CISepiaTone", img: beginImage)
        
        
    }
    
    /* Filter 2 - Fade */
    @IBAction func filterTwoButton(sender: AnyObject) {
        effectImageDisplay.image = applyFilter("CIPhotoEffectFade", img: beginImage)
    }
    
    
    /* Filter 3 - Black-and-White  */
    @IBAction func filterThreeButton(sender: AnyObject) {
        effectImageDisplay.image = applyFilter("CIPhotoEffectNoir", img: beginImage)
    }
    
    /*Sliders */
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
    
    func applyFilter(nameFilter: String, img: CIImage) -> UIImage {
        filter = CIFilter(name: nameFilter)
        filter.setValue(img, forKey: kCIInputImageKey)
        filter.setDefaults() // default values
        
        let brightnessFil = CIFilter(name: "CIColorControls")
        brightnessFil.setValue(filter.outputImage, forKey: kCIInputImageKey)
        brightnessFil.setValue(1 - self.brightness, forKey: "inputBrightness")
        brightnessFil.setValue(1 - self.contrast, forKey: "inputBrightness")
        
        context = CIContext(options: nil)
        let renderedImage = context.createCGImage(brightnessFil.outputImage, fromRect: brightnessFil.outputImage.extent())
        let newImage = UIImage(CGImage: renderedImage, scale: self.imageReceived.scale, orientation: self.imageReceived.imageOrientation)
        
        
        //        let filteredImage = filter.outputImage
        //        context = CIContext(options: nil)
        //        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        //        let newImage = UIImage(CGImage: renderedImage, scale: self.imageReceived.scale, orientation: self.imageReceived.imageOrientation)
        return newImage!
        
    }
    
//    func applyFilter (filteredImg: CIImage) -> UIImage {
//        context = CIContext(options: nil)
//        let renderedImage = context.createCGImage(filteredImg, fromRect: filteredImg.extent())
//        
//        let newImage = UIImage(CGImage: renderedImage, scale: self.imageReceived.scale, orientation: self.imageReceived.imageOrientation)
//        
//        return newImage!
//        
//    }
    
}
