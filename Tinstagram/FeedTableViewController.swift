//
//  FeedTableViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/15/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

//protocol MyCustomCellDelegator {
//    func callSegueFromCell(myData dataobject: AnyObject)
//}

class FeedTableViewController: UITableViewController{

    var currentUser: PFUser!
    
    var viewUser: PFUser?
    
    var feedFiles = [PFFile]()
    
    var feedUser = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabController = self.tabBarController as! MainTabBarController
        currentUser = tabController.currentUser

    }
    
    override func viewDidAppear(animated: Bool) {
        feedFiles.removeAll(keepCapacity: false)
        feedUser.removeAll(keepCapacity: false)
        if let followingArray: [String] = currentUser.objectForKey("following") as? [String]{
            var imageQuery = PFQuery(className: "Image")
            imageQuery.whereKey("userId", containedIn: followingArray)
            imageQuery.orderByDescending("createdAt")
            imageQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    if let objects = objects{
                        for object in objects{
                            var userQuery = PFQuery(className: "_User")
                            userQuery.whereKey("objectId", equalTo: object.objectForKey("userId") as! String)
                            var results = userQuery.findObjects()!
                            for result in results{
                                self.feedUser.append(result.objectForKey("username") as! String)
                            }
                            self.feedFiles.append(object.objectForKey("image") as! PFFile)
                            self.tableView.reloadData()
                        }
                        println("view: \(self.feedUser.count)")
                    }
                }
            
            })
            
        }
        
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
        return feedFiles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! feedCell
        cell.username.setTitle("\(self.feedUser[indexPath.row])",forState: .Normal)
        cell.username.tag = indexPath.row
        self.feedFiles[indexPath.row].getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if error == nil{
                let image = UIImage(data: imageData!)
                cell.imageFeed.image = image
                cell.imageFeed.contentMode = UIViewContentMode.ScaleAspectFit
            }
        })

        return cell
    }
    
    @IBAction func viewUserDetail(sender: UIButton){
        println("Click::Event")
        let username = self.feedUser[sender.tag] as String
        var userQuery = PFQuery(className: "_User")
        userQuery.whereKey("username", equalTo: username)
        var userObject = userQuery.getFirstObject()
        if let userObject = userObject as? PFUser{
            viewUser = userObject
        }
        
        
        performSegueWithIdentifier("viewuser", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSegue")
        if let userProfileController = segue.destinationViewController as? ProfileViewController{
            if let identifier = segue.identifier {
                switch identifier {
                case "viewuser":
                    if let theSender = sender as? FeedTableViewController{
                        println("aksdjflasjdf")
                        userProfileController.viewUser  = self.viewUser
                        userProfileController.currentUser = self.currentUser
                        
                        
                    }
                default: break
                }
            }
            
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        
        
        if identifier == "viewuser"{
            if viewUser == nil{
                return false
            }else{
                return true
            }
        }
        return true
    }

    func callSegueFromCell(myData dataobject: AnyObject) {
        viewUser = dataobject as? PFUser
    }
    
    
    

}

class feedCell: UITableViewCell{
    
    
    @IBOutlet weak var username: UIButton!
    
    
    @IBOutlet weak var imageFeed: UIImageView!
    

}



