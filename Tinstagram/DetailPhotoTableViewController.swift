//
//  DetailPhotoViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/13/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class DetailPhotoTableViewController: UITableViewController {
    
    var imageID:String!
    var imageFile:PFFile!
    var imageOwner:String!
    var viewUser:PFUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        println(imageID)
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        imageObject.fetchIfNeeded()
        imageObject.pin()
        var userQuery = PFQuery(className: "_User")
        viewUser = userQuery.getObjectWithId(imageObject["userId"] as! String) as? PFUser
        println(viewUser)
    }

    @IBAction func makeAComment(sender: UIButton) {
        performSegueWithIdentifier("showcomment", sender: self)
        
    }
    
//    @IBAction func viewUserDetail(sender:UIButton){
//        performSegueWithIdentifier("viewuser", sender: self)
//    }
    
    @IBAction func likeAPhoto(sender:UIButton){
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        var likeAct = PFObject(className: "Activity")
        likeAct["fromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        imageObject.fetchIfNeeded()
        likeAct["toUser"] = PFObject(withoutDataWithClassName: "_User", objectId: imageObject["userId"] as? String)
        likeAct["type"] = "like"
        likeAct["photo"] = imageObject
        likeAct.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
            if success {
                println("like saved")
            } else {
                println(error)
            }
            
        }
        
        imageObject.incrementKey("likes", byAmount: 1)
        imageObject.save()
        var indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! TimelineTableViewCell
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        imageObject.fetchIfNeeded()
        if let numberOfLikes = imageObject["likes"] as? Int{
            cell.like.setTitle(("\(numberOfLikes)"), forState: .Normal)
        }
        var activityQuery  = PFQuery(className: "Activity")
        activityQuery.whereKey("type", equalTo: "like")
        activityQuery.includeKey("fromUser")
        activityQuery.includeKey("photo")
        activityQuery.whereKey("photo", equalTo: imageObject)
        activityQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        var result = activityQuery.findObjects()
        if result!.count  == 0{
            cell.like.enabled = true
        }else{
            cell.like.enabled = false
        }
        cell.username.setTitle(viewUser!.username,forState: .Normal)
        self.imageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if error == nil{
                let image = UIImage(data: imageData!)
                cell.imageFeed.image = image
                
                cell.imageFeed.contentMode = UIViewContentMode.ScaleAspectFit
            }
        })
        imageObject.unpin()
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
//            case "viewuser":
//                if let userProfileController = segue.destinationViewController as? ProfileViewController{
//                    if let theSender = sender as? DetailPhotoTableViewController{
//                        userProfileController.viewUser  = self.viewUser
//                        userProfileController.currentUser = PFUser.currentUser()
//                    }
//                }
            case "showcomment":
                if let commentController = segue.destinationViewController as? CommentViewController{
                    if let theSender = sender as? DetailPhotoTableViewController{
                        commentController.imageID = self.imageID
                    }
                }
            default: break
            }
        }
    }

}
