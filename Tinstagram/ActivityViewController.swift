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
    
    
    var objects = [String]()
    var youObjects = [String]()
    var currentUser: PFUser!
    var fromUser = [PFUser]()
    var toUserID: String!
    
    
    func findYourActivity() -> Void {
        
        var yourActivityQuery = PFQuery(className: "Activity")
        var toUserObject = PFObject(withoutDataWithClassName: "_User", objectId:toUserID )
        //var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageID)
        //commentQuery.includeKey("photo")
        yourActivityQuery.includeKey("fromUser")
        yourActivityQuery.whereKey("type",equalTo: "follow")
        yourActivityQuery.whereKey("toUser", equalTo: toUserObject)
        
        yourActivityQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil{
                //println(objects!.count)
                if let aaa = objects as! [PFObject]?{
                    for item in aaa{
                        let item = item["fromUser"] as! PFUser
                        println(item.username)
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
                    
                }
                //println(self.fromUser)
                self.youTableView.reloadData()
                
            }
            
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let tabController = self.tabBarController as? MainTabBarController {
            currentUser = tabController.currentUser
        }
        
        toUserID = currentUser.objectId
        
        findYourActivity()
        
        self.objects.append("iPhone")
        self.objects.append("Apple Watch")
        self.objects.append("Mac")
        
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
            return self.objects.count
        }
            
        else { // tableView == _secondTable
            // Do something else
            //return self.youObjects.count
            return self.fromUser.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {if tableView == self.followingTableView {
        
        // Allocates a Table View Cell
        let aCell = tableView.dequeueReusableCellWithIdentifier("followingActivityCell",
            forIndexPath: indexPath) as! ActivityTableViewCell
        // Sets the text of the Label in the Table View Cell
        aCell.titleLabel.text = self.objects[indexPath.row]
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
        aCell.followerButton.setTitle(self.fromUser[indexPath.row].username, forState: UIControlState.Normal)
        return aCell
        }
    }
    
    
    
}