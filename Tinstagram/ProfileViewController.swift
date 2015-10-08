//
//  ProfileViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/9/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var currentUser: PFUser!
    
    var viewUser: PFUser?
    @IBOutlet weak var editProfile: UIButton!

    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var profilePic: PFImageView!
    @IBOutlet weak var posts: UILabel!
    
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    @IBOutlet weak var photoCollection: PhotoCollectionView!
    
    
    var userImageFiles = [PFFile]()
    var selectedPhoto: PFFile?
    

    override func viewDidLoad(){
        println(viewUser)
        photoCollection.delegate = self;
        photoCollection.dataSource = self;
        
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
        println("THISSSSSS is THE Length" + "\(length)")
        if length > 0{
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if (error == nil){
                    if let objects = objects{
                        for object in objects{
                            self.userImageFiles.append(object.objectForKey("image") as! PFFile)
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
                cell.myImage.image = image
            }
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedPhoto = userImageFiles[indexPath.row]
        println("collectionView::didDeselectItemAtIndexPath")
        performSegueWithIdentifier("photoinfo", sender: self)
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
                            println(photo)
                        }
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





