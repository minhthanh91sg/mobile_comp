//
//  FullPhotoViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/8/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class FullPhotoViewController: UIViewController {

    @IBOutlet weak var fullSizeImage: UIImageView!
    
    var imageFile: PFFile!
    var imageID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("FullPhotoViewController:::::::\(imageID)")
        println(imageFile)
        imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil{
                    let image = UIImage(data: imageData!)
                    self.fullSizeImage.image = image
                }
        }
        
        fullSizeImage.contentMode = UIViewContentMode.ScaleAspectFit
        

        // Do any additional setup after loading the view.
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
