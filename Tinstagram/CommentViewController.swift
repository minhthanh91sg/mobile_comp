//
//  CommentTableViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/10/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var imageID: String!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBAction func sendComment(sender: AnyObject) {
        if commentTextField.text != ""{
            var query = PFQuery(className:"Image")
            var imageObject = query.getObjectWithId(imageID)
            var imageOwnerId = imageObject?.objectForKey("userId") as! String
            var commentAct = PFObject(className: "Activity")
            commentAct["fromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
            commentAct["toUser"] = PFObject(withoutDataWithClassName: "_User", objectId: imageOwnerId)
            commentAct["type"] = "comment"
            commentAct["content"] = commentTextField.text
            commentAct["photo"] = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
            commentAct.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                if success {
                    println("comment saved")
                } else {
                    println(error)
                }
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("CommentViewController \(imageID)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }

}

class CommentCell: UITableViewCell{
    
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var content: UILabel!
}





