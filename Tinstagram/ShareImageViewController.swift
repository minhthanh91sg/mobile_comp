//
//  ShareImageViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 8/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ShareImageViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var editedImageDisplay: UIImageView!
    
    /* Image received from ImageEffectViewController */
    var imageReceived: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CImageEffectViewController
        editedImageDisplay.image = imageReceived
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
