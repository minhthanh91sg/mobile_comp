//
//  FeedTableViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/15/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {

    var currentUser: PFUser!
    
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
            imageQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    if let objects = objects{
                        for object in objects{
                            self.feedUser.append(object.objectForKey("userId") as! String)
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
        println("Test2:\(feedFiles.count)")
        return feedFiles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! feedCell
        cell.username.text = self.feedUser[indexPath.row]
        println("test:\(self.feedUser[indexPath.row])")
        self.feedFiles[indexPath.row].getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if error == nil{
                let image = UIImage(data: imageData!)
                cell.imageFeed.image = image
            }
        })

        return cell
    }



}
class feedCell: UITableViewCell{
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var imageFeed: UIImageView!
}


