//
//  ProfileViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/9/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource, UITableViewDelegate{
    
    var currentUser: PFUser!
    
    var viewUser: PFUser?
    @IBOutlet weak var editProfile: UIButton!

    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var profilePic: PFImageView!
    @IBOutlet weak var posts: UILabel!
    
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    @IBOutlet weak var photoCollection: PhotoCollectionView!
    
    @IBOutlet weak var feedTable: UITableView!
    
    @IBOutlet weak var switchCollectionTable: UISegmentedControl!

    
    @IBAction func switchCollectionTable(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
            case 0:
                self.feedTable.hidden = true
                self.photoCollection.hidden = false
                photoCollection.reloadData()
            case 1:
                self.photoCollection.hidden = true
                self.feedTable.hidden = false
                feedTable.reloadData()
            default:
                break
        }
    }
    
    var userImageFiles = [PFFile]()
    var imageIDs = [String]()
    var selectedPhoto: PFFile?
    var selectedImageId: String?
    
    @IBAction func makeComment(sender: UIButton) {
        selectedPhoto = userImageFiles[sender.tag]
        selectedImageId = imageIDs[sender.tag]
        performSegueWithIdentifier("showcomment", sender: self)
        println("SEGUE::::NOW")
        
    }
    
    

    override func viewDidLoad(){
        switchCollectionTable.selectedSegmentIndex = 0
        self.feedTable.hidden = true
        self.photoCollection.hidden = false
        println(viewUser)
        photoCollection.delegate = self
        photoCollection.dataSource = self
        feedTable.delegate = self
        feedTable.dataSource = self
        
        println("ProfileViewController::viewDidLoad::\(currentUser)")
        
        if let tabController = self.tabBarController as? MainTabBarController {
            currentUser = tabController.currentUser
            if viewUser == nil{
                self.showUserInfo(currentUser)
                self.showCollection(currentUser)
            }else{
                self.showUserInfo(viewUser!)
                self.showCollection(viewUser!)
            }
        }
    }
    
    //show user info
    func showUserInfo(user: PFUser){
        
        if let file: PFFile = user.objectForKey("profilePicture") as? PFFile{
            profilePic.file = file
            profilePic.loadInBackground()
            profilePic.contentMode = UIViewContentMode.ScaleAspectFit
            
        }
        
        self.navigationItem.title = user.username
        editProfile.backgroundColor = UIColor.grayColor()
        if let firstName: String = user.objectForKey("firstName") as? String{
            if let lastName: String = user.objectForKey("lastName") as? String{
                fullName.text = firstName + " " + lastName
                fullName.adjustsFontSizeToFitWidth = true
            }
            
        }
        
        if let followersArray: [String] = user.objectForKey("follower") as? [String]{
            var count = followersArray.count
            followers.text = "\(count)"
        }
        
        if let followingArray: [String] = user.objectForKey("following") as? [String]{
            var count = followingArray.count
            following.text = "\(count)"
        }
        
        if let postArray: [String] = user.objectForKey("post") as? [String]{
            var count = postArray.count
            posts.text = "\(count)"
        }
    }
    
    
    
    //get data for collection view
    func showCollection(user: PFUser){
        //userImageFiles.removeAll(keepCapacity: false)
        
        var query: PFQuery = PFQuery(className: "Image")
        query.whereKey("userId", equalTo: user.objectId!)
        var length = query.countObjects()
        if length > 0{
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if (error == nil){
                    if let objects = objects{
                        for object in objects{
                            self.userImageFiles.append(object.objectForKey("image") as! PFFile)
                            self.imageIDs.append(object.objectId as String!)
                            println("This is the length of the Images Files Array  " + "\(self.userImageFiles.count)")
                            self.photoCollection.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    
    func getUserImagesIds(user: PFUser) -> [String]?{
        return user.objectForKey("imageId") as! [String]?
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImageFiles.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sharedphoto", forIndexPath: indexPath) as! PhotoCollectionViewCell
        self.userImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil{
                let image = UIImage(data: imageData!)
                println("collectionView::cellForItemAtIndexPath")
                cell.myImage.image = image
                cell.myImage.contentMode = UIViewContentMode.ScaleAspectFit
            }
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedPhoto = userImageFiles[indexPath.row]
        selectedImageId = imageIDs[indexPath.row]
        performSegueWithIdentifier("photoinfo", sender: self)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userImageFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userfeed",forIndexPath: indexPath) as! TimelineTableViewCell
        var nameOfUser = currentUser.objectForKey("username") as! String
        cell.username.setTitle(nameOfUser, forState: .Normal)
        cell.username.sizeToFit()
        cell.comment.tag = indexPath.row
        self.userImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil{
                let image = UIImage(data: imageData!)
                println("tableView::cellForRowAtIndexPath")
                cell.imageFeed.image = image
                cell.imageFeed.contentMode = UIViewContentMode.ScaleAspectFit
            }
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView:
        UICollectionView) -> Int {
            return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "editprofile":
                if let editProfileController = segue.destinationViewController as? EditProfileTableViewController{
                    if let theSender = sender as? ProfileViewController{
                        editProfileController.currentUser = sender?.currentUser
                        break
                    }
                    
                }
            case "photoinfo":
                if let fullPhotoController = segue.destinationViewController as? FullPhotoViewController{
                    if let theSender = sender as? ProfileViewController{
                        if let photo = selectedPhoto as PFFile!{
                            fullPhotoController.imageFile = photo
                            fullPhotoController.imageID = selectedImageId
                            println(photo)
                        }
                    }
                }
            case "showcomment":
                if let commentViewController = segue.destinationViewController as? CommentViewController{
                    if let theSender = sender as? ProfileViewController{
                        commentViewController.imageID = selectedImageId
                    }
                }
                
            default: break
            }
        }
        
        

    }
    
}

class PhotoCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
    
    
}


class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myImage: UIImageView!
}

