//
//  ActivityViewController.swift
//  Tinstagram
//
//  Created by Lu Fan on 12/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var followingTableView: UITableView! = UITableView()
    
    @IBOutlet weak var youTableView: UITableView! = UITableView()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //var objects = [String]()
    //var youObjects = [String]()
    var currentUser: PFUser!
    var fromUser = [PFUser]()
    var fromUser002 = [PFUser]()
    var toUser002 = [PFUser]()
    var yourActivitiesArray = [PFObject]()
    var followingActivitiesArray = [PFObject]()
    var toUserID: String!
    var viewUser: PFUser!
    
    
    
    @IBAction func followingOrTou(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            youTableView.hidden = true
            followingTableView.hidden = false
        case 1:
            followingTableView.hidden = true
            youTableView.hidden = false
        default:
            break;
        }
        
    }
    
    
    
    
    @IBAction func linkToUser(sender: UIButton) {
        println("Click::Event")
        viewUser = self.fromUser[sender.tag]
        
        performSegueWithIdentifier("viewuser", sender: self)
    }
    
    @IBAction func optionalButtonAct(sender: UIButton) {
        
        
    }
    
    func findYourActivity() -> Void {
        
        //if let tabController = self.tabBarController as? MainTabBarController {
        //    currentUser = tabController.currentUser
        //}
        //toUserID = currentUser.objectId
        
        toUserID = PFUser.currentUser()?.objectId
      
        
        
        var yourActivityQuery = PFQuery(className: "Activity")
        var toUserObject = PFObject(withoutDataWithClassName: "_User", objectId:toUserID )
        //var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        //commentQuery.includeKey("photo")
        yourActivityQuery.includeKey("fromUser")
        //yourActivityQuery.whereKey("type",equalTo: "follow")
        yourActivityQuery.whereKey("toUser", equalTo: toUserObject)
        yourActivityQuery.whereKey("fromUser", notEqualTo: toUserObject)
        
        yourActivityQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil{
                //println(objects!.count)
                if let aaa = objects as! [PFObject]?{
                    for item in aaa{
                        let item = item["fromUser"] as! PFUser
                        //println(item.username)
                    }
                }
                
                
                if let activityObjectArray = objects as! [PFObject]?{
                    //self.fromUser.removeAll(keepCapacity: false)
                    for activityObject in activityObjectArray{
                        //println((commentObject["photo"]))
                        //println(activityObject["fromUser"])
                        self.fromUser.append(activityObject["fromUser"] as! PFUser)
                        //println(self.fromUser)
                    }
                
                    
                    if let activityObjectArray = objects as! [PFObject]?{
                        //self.yourActivitiesArray = activityObjectArray
                        for item in activityObjectArray{
                            self.yourActivitiesArray.append(item)
                            let indexItem = find(activityObjectArray,item)
                            if indexItem > 4{
                                break;
                            }
                        }
                    }
                    
                }
                //println(self.fromUser)
                self.youTableView.reloadData()
                
            }
            
        }
    }
    
    func findFollowingActivity() -> Void {
        
        var followingActivityQuery = PFQuery(className: "Activity")
        
        //var toUserObject = PFObject(withoutDataWithClassName: "_User", objectId:toUserID )
        //var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        //commentQuery.includeKey("photo")
        //followingActivityQuery.includeKey("fromUser")
        //yourActivityQuery.whereKey("type",equalTo: "follow")
        
        var currentUserID : String!
        currentUserID = PFUser.currentUser()?.objectId
        var followingUsers = [PFObject]()
        
        //var yourActivityQuery = PFQuery(className: "Activity")
        var currentUserObject = PFObject(withoutDataWithClassName: "_User", objectId: currentUserID )
        
        
        if let followingUserArrayString = PFUser.currentUser()!["following"] as? [String] {
            
            for item in followingUserArrayString{
                var followingUserObject = PFObject(withoutDataWithClassName: "_User", objectId: item )
                followingUsers.append(followingUserObject)
                
            }
            println("func findFollowingActivity() -> Void ::::::\(followingUsers)")
            
            followingActivityQuery.whereKey("fromUser", containedIn:followingUsers)
            followingActivityQuery.whereKey("fromUser", notEqualTo: currentUserObject)
            
            followingActivityQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
                if error == nil{
                    //println(objects!.count)
                    if let aaa = objects as! [PFObject]?{
                        for item in aaa{
                            let item = item["fromUser"] as! PFUser
                            //println(item.username)
                        }
                    }
                    
                    
                    if let activityObjectArray = objects as! [PFObject]?{
                        //self.fromUser.removeAll(keepCapacity: false)
                        for activityObject in activityObjectArray{
                            //println((commentObject["photo"]))
                            //println(activityObject["fromUser"])
                            self.fromUser002.append(activityObject["fromUser"] as! PFUser)
                            self.toUser002.append(activityObject["toUser"] as! PFUser)
                            //println(self.fromUser)
                        }
                    
                        
                    }
                    
                    if let activityObjectArray = objects as! [PFObject]?{
                        //self.followingActivitiesArray = activityObjectArray
                        for item in activityObjectArray{
                            self.followingActivitiesArray.append(item)
                            let indexItem = find(activityObjectArray,item)
                            if indexItem > 4{
                                break;
                            }
                        }
                        
                        
                        //println(self.followingActivitiesArray)
                    }
            
            
            
        }
        
        
                        //println(self.fromUser)
                self.followingTableView.reloadData()
                
            }
            
        }
    }

    
    
    
    
    override func viewDidAppear(animated: Bool) {
        self.fromUser.removeAll(keepCapacity:false)
        self.fromUser002.removeAll(keepCapacity: false)
        self.toUser002.removeAll(keepCapacity: false)
        self.yourActivitiesArray.removeAll(keepCapacity: false)
        self.followingActivitiesArray.removeAll(keepCapacity: false)
        findYourActivity()
        findFollowingActivity()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        //findYourActivity()
        //findFollowingActivity()
        
        
        //self.objects.append("iPhone")
        //self.objects.append("Apple Watch")
        //self.objects.append("Mac")
        
        //self.youObjects.append("iPhone2")
        //self.youObjects.append("Apple Watch2")
        //self.youObjects.append("Mac2")
        //self.youObjects.append(toUserID)
        
        //println(self.fromUser.count)
        
        //if self.fromUser.isEmpty == false {
        //    for item in self.fromUser{
        //        self.youObjects.append(item.username!)
        //    }
        //}
        
        
        followingTableView.dataSource = self
        followingTableView.delegate = self
        youTableView.dataSource = self
        youTableView.delegate = self
        
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
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int
    {
        
        if tableView == self.followingTableView {
            // Do something
            return self.followingActivitiesArray.count
        }
            
        else { // tableView == _secondTable
            // Do something else
            //return self.youObjects.count
            //return self.fromUser.count
            return self.yourActivitiesArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if tableView == self.followingTableView {
        
        // Allocates a Table View Cell
        let aCell = tableView.dequeueReusableCellWithIdentifier("followingActivityCell",
            forIndexPath: indexPath) as! ActivityTableViewCell
        // Sets the text of the Label in the Table View Cell
        if let actType = followingActivitiesArray[indexPath.row]["type"] as? String {
            
            if actType == "follow" {
                
                if let user = followingActivitiesArray[indexPath.row]["fromUser"] as? PFUser, user2 = yourActivitiesArray[indexPath.row]["toUser"] as? PFUser {
                    user.fetchIfNeeded()
                    user2.fetchIfNeeded()
                    aCell.followerButton.setTitle(user.username, forState: UIControlState.Normal)
                    aCell.optionalButton.setTitle(user2.username, forState: UIControlState.Normal)
                    aCell.titleLabel.text = "started following"
                    //aCell.follower = fromUser[indexPath.row]
                    //aCell.optionalButton.hidden = true
                }
                
                
            }
            else if actType == "comment" {
                
                
                if let user = followingActivitiesArray[indexPath.row]["fromUser"] as? PFUser {
                    user.fetchIfNeeded()
                    //user2.fetchIfNeeded()
                    aCell.followerButton.setTitle(user.username, forState: UIControlState.Normal)
                    aCell.titleLabel.text = "commented on a"
                    //aCell.follower = fromUser[indexPath.row]
                    aCell.optionalButton.setTitle("photo", forState: UIControlState.Normal)
                    //aCell.optionalButton.hidden = true
                }
            }
            else if actType == "like" {
                
                if let user = followingActivitiesArray[indexPath.row]["fromUser"] as? PFUser {
                    
                    user.fetchIfNeeded()
                    //user2.fetchIfNeeded()
                    
                    aCell.followerButton.setTitle(user.username, forState: UIControlState.Normal)
                    aCell.titleLabel.text = "liked a"
                    //aCell.follower = fromUser[indexPath.row]
                    aCell.optionalButton.setTitle("photo", forState: UIControlState.Normal)
                }
                
                
                
            }
            
            
        }
        
        
        //aCell.titleLabel.text = self.objects[indexPath.row]
        return aCell
    }
        
    else {
        // Allocates a Table View Cell
        //println(self.fromUser)
        //println(self.fromUser.isEmpty)
        let aCell = tableView.dequeueReusableCellWithIdentifier("youActivityCell",
            forIndexPath: indexPath) as! ActivityTableViewCell
        // Sets the text of the Label in the Table View Cell
        //aCell.titleLabel.text = self.youObjects[indexPath.row]
        //aCell.titleLabel.text = self.fromUser[indexPath.row].username
        //if yourActivitiesArray.isEmpty == false
        
        if let actType = yourActivitiesArray[indexPath.row]["type"] as? String {
            
            if actType == "follow" {
                
                if let user = yourActivitiesArray[indexPath.row]["fromUser"] as? PFUser {
                    aCell.followerButton.setTitle(fromUser[indexPath.row].username, forState: UIControlState.Normal)
                    aCell.titleLabel.text = "started following you"
                    //aCell.follower = fromUser[indexPath.row]
                    aCell.optionalButton.hidden = true
                }
                
                
            }
            else if actType == "comment" {
                
                
                if let user = yourActivitiesArray[indexPath.row]["fromUser"] as? PFUser {
                    aCell.followerButton.setTitle(fromUser[indexPath.row].username, forState: UIControlState.Normal)
                    aCell.titleLabel.text = "commented on your"
                    //aCell.follower = fromUser[indexPath.row]
                    aCell.optionalButton.setTitle("photo", forState: UIControlState.Normal)
                   //aCell.optionalButton.hidden = true
                }
            }
            else if actType == "like" {
                    
                    
                    if let user = yourActivitiesArray[indexPath.row]["fromUser"] as? PFUser {
                        aCell.followerButton.setTitle(fromUser[indexPath.row].username, forState: UIControlState.Normal)
                        aCell.titleLabel.text = "liked your"
                        //aCell.follower = fromUser[indexPath.row]
                        aCell.optionalButton.setTitle("photo", forState: UIControlState.Normal)
                }
                

                
            }
            
            
        }
        
        
        return aCell
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSegue")
        
        if let identifier = segue.identifier {
            switch identifier {
            case "viewuser":
                if let userProfileController = segue.destinationViewController as? ProfileViewController{
                    if let theSender = sender as? ActivityViewController{
                        println("aksdjflasjdf")
                        userProfileController.viewUser  = self.viewUser
                        userProfileController.currentUser = self.currentUser
                    }
                }
                default: break
                
            }
            
        }
        
    }
    
    
    
}