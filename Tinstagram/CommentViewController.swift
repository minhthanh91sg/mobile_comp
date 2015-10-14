//
//  CommentTableViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/10/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {

    var imageID: String!
    var comments =  [String]()
    var fromUser = [PFUser]()
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var commentTable: UITableView!
    
    @IBAction func sendComment(sender: UIButton) {
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
                    imageObject?.incrementKey("comments",byAmount:1)
                    imageObject?.save()
                } else {
                    println(error)
                }
                
            }
            
            commentTextField.text = ""
            getCommentsForPhoto()
            commentTable.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommentsForPhoto()
        commentTable.dataSource = self
        commentTable.delegate = self
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        commentTable.estimatedRowHeight = 68.0
        commentTable.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func getCommentsForPhoto() -> Void{
        var commentQuery = PFQuery(className: "Activity")
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        commentQuery.includeKey("photo")
        commentQuery.includeKey("fromUser")
        commentQuery.whereKey("type",equalTo: "comment")
        commentQuery.whereKey("photo", equalTo: imageObject)
        
        commentQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil{
                if let commentObjectArray = objects as! [PFObject]?{
                    self.comments.removeAll(keepCapacity: false)
                    for commentObject in commentObjectArray{
                        self.comments.append(commentObject["content"] as! String)
                        self.fromUser.append(commentObject["fromUser"] as! PFUser)
                    }
                    
                }
                self.commentTable.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as! CommentCell
        cell.username.setTitle(fromUser[indexPath.row]["username"] as? String, forState: .Normal)
        cell.content.text = comments[indexPath.row]
        return cell
    }
    
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 250)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 250)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.4
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
}

class CommentCell: UITableViewCell{
    
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var content: UILabel!
}





