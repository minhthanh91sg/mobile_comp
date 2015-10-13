//
//  ProfileViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/9/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    
    @IBAction func Following(sender: UIButton) {
        
        viewUser?.addObject(currentUser.objectId! as String, forKey: "follower")
        currentUser?.addObject(viewUser!.objectId! as String, forKey: "following")
        viewUser?.save()
        editProfile.setTitle("Followed", forState: .Normal)
        editProfile.enabled = false
        
        var followAct = PFObject(className: "Activity")
        followAct["fromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: currentUser.objectId!)
        followAct["toUser"] = PFObject(withoutDataWithClassName: "_User", objectId: viewUser?.objectId)
        followAct["type"] = "follow"
        followAct.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
            if success {
                println("follow saved")
            } else {
                println(error)
            }
        
    }
    }
    
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
    
    @IBAction func likeAPhoto(sender: UIButton) {
        selectedImageId = imageIDs[sender.tag]
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: selectedImageId)
        var likeAct = PFObject(className: "Activity")
        likeAct["fromUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        if viewUser != nil{
            likeAct["toUser"] = PFObject(withoutDataWithClassName: "_User", objectId: viewUser!.objectId)
        }else{
            likeAct["toUser"] = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()?.objectId)
        }
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
        self.feedTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    
    var profilePicPicker: UIImagePickerController? = UIImagePickerController()
    

    override func viewDidLoad(){
        switchCollectionTable.selectedSegmentIndex = 0
        self.feedTable.hidden = true
        self.photoCollection.hidden = false
        editProfile.setTitle("Your Profile", forState: .Normal)
        
        println(viewUser)
        photoCollection.delegate = self
        photoCollection.dataSource = self
        feedTable.delegate = self
        feedTable.dataSource = self
        profilePicPicker?.delegate = self
        editProfile.enabled = false
        
        
        
        /* Tap Gesture Recognizer */
        let tapGestureForProfilePic = UITapGestureRecognizer(target: self, action: (Selector:"selectProfilePic:"))
        profilePic.addGestureRecognizer(tapGestureForProfilePic)
        
        
        
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
    
        
        if(viewUser != nil) {
            if let follower: [String] = viewUser!.objectForKey("follower") as? [String]{
                
                println(follower)
                println(currentUser.objectId!)
                if contains(follower, currentUser.objectId!) {
                    
                    editProfile.setTitle("Following", forState: UIControlState.Normal)
                    editProfile.enabled = false
                } else{
                    
                    editProfile.setTitle("Follow", forState: UIControlState.Normal)
                    editProfile.enabled = true
                }

            
            
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
        
        
        var query = PFQuery(className: "Image")
        println("Query count post")
        query.whereKey("userId", equalTo: user.objectId!)
        var count = query.countObjects()
        println(count)
        posts.text = "\(count)"
        
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
        performSegueWithIdentifier("fullphoto", sender: self)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userImageFiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userfeed",forIndexPath: indexPath) as! TimelineTableViewCell
        var nameOfUser: String
        if viewUser != nil{
            nameOfUser = viewUser!.objectForKey("username") as! String
        }else{
            nameOfUser = currentUser["username"] as! String
        }
        
        
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: imageIDs[indexPath.row])
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
        cell.username.setTitle(nameOfUser, forState: .Normal)
        cell.username.sizeToFit()
        cell.comment.tag = indexPath.row
        cell.like.tag = indexPath.row
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
            case "fullphoto":
                if let fullPhotoController = segue.destinationViewController as? DetailPhotoTableViewController{
                    if let theSender = sender as? ProfileViewController{
                        if let photo = selectedPhoto as PFFile!{
                            fullPhotoController.imageFile = photo
                            fullPhotoController.imageID = selectedImageId
                        }
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
    
    // MARK: - Profile Pic Picker Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.contentMode = .ScaleAspectFit
            profilePic.image = pickedImage
            saveProfilePicOnServer(pickedImage)
            dismissViewControllerAnimated(true, completion: nil)
            saveProfilePicOnServer(pickedImage)
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: - Profile Pic
    
    func selectProfilePic (img: AnyObject){
        println("Tap on profile view")
        selectGallery()
        
        
    }
    
    /* Picks an Image from Gallery */
    func selectGallery(){
        println("Gallery Selected")
        self.profilePicPicker!.allowsEditing = false
        self.profilePicPicker!.sourceType = .SavedPhotosAlbum
        self.presentViewController(profilePicPicker!, animated: true, completion: nil)
        
    }
    
    func saveProfilePicOnServer(profilePic: UIImage) {
        
        let user = PFUser.currentUser()
        let imageData = UIImageJPEGRepresentation(profilePic, 0.5) //image compression
        let imageFile = PFFile(data: imageData)
        
        
        user?.setObject(imageFile, forKey: "profilePicture")
        
        user?.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("object was saved")
            } else {
                // There was a problem, check error.description
                println("Object not saved")
            }
        }
        
        
        
        
    }
    
    
    
    
    
}

class PhotoCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
    
    
}


class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myImage: UIImageView!
}

