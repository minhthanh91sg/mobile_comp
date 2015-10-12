//
//  FeedTableViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/15/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit
import CoreBluetooth


class FeedTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate{

    var currentUser: PFUser!
    
    var viewUser: PFUser?
    
    var feedFiles = [PFFile]()
    
    var feedImageIds = [String]()
    
    var feedUser = [String]()
    
    var selectedImageId:String?
    
    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    let serviceUUIDs = CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")
    let CharacteristicUUID = CBUUID(string: "843ddfb6-4355-4250-bae0-167df24161c6")
    
    let data = NSMutableData()
    var receivedData : NSString?


    @IBAction func makeAComment(sender: UIButton) {
        selectedImageId = feedImageIds[sender.tag]
        performSegueWithIdentifier("showcomment", sender: self)
        
    }
    
    
    @IBAction func likeAPhoto(sender: UIButton) {
        selectedImageId = feedImageIds[sender.tag]
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: selectedImageId)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        scan()
        
        let tabController = self.tabBarController as! MainTabBarController
        currentUser = tabController.currentUser
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    
    func refreshData(refreshControl: UIRefreshControl) {
        if let followingArray: [String] = currentUser.objectForKey("following") as? [String]{
            var imageQuery = PFQuery(className: "Image")
            imageQuery.whereKey("userId", containedIn: followingArray)
            imageQuery.orderByDescending("createdAt")
            imageQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil{
                    self.feedFiles.removeAll(keepCapacity: false)
                    self.feedUser.removeAll(keepCapacity: false)
                    if let objects = objects{
                        for object in objects{
                            var userQuery = PFQuery(className: "_User")
                            userQuery.whereKey("objectId", equalTo: object.objectForKey("userId") as! String)
                            var results = userQuery.findObjects()!
                            for result in results{
                                self.feedUser.append(result.objectForKey("username") as! String)
                            }
                            if let idStr: String = object.objectId as String!{
                                self.feedImageIds.append(idStr)
                            }
                            self.feedFiles.append(object.objectForKey("image") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }
                }
            
            })

            
        }
        self.refreshControl?.endRefreshing()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! TimelineTableViewCell
        cell.username.setTitle("\(self.feedUser[indexPath.row])",forState: .Normal)
        cell.username.tag = indexPath.row
        cell.comment.tag = indexPath.row
        cell.like.tag = indexPath.row
        var imageObject = PFObject(withoutDataWithClassName: "Image", objectId: feedImageIds[indexPath.row])
        imageObject.fetchIfNeeded()
        if let numberOfLikes = imageObject["likes"] as? Int{
            cell.like.setTitle(("\(numberOfLikes)"), forState: .Normal)
        }
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
        
            if let identifier = segue.identifier {
                switch identifier {
                case "viewuser":
                    if let userProfileController = segue.destinationViewController as? ProfileViewController{
                        if let theSender = sender as? FeedTableViewController{
                            println("aksdjflasjdf")
                            userProfileController.viewUser  = self.viewUser
                            userProfileController.currentUser = self.currentUser
                        }
                    }
                case "showcomment":
                    if let commentController = segue.destinationViewController as? CommentViewController{
                        if let theSender = sender as? FeedTableViewController{
                            commentController.imageID = self.selectedImageId
                        }
                    }
                default: break
                
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
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state != .PoweredOn{
            return
        }
        
        scan()
    }
    
    func scan() {
        
        centralManager?.scanForPeripheralsWithServices([serviceUUIDs], options: nil)
        print("Scan Started")
        print(serviceUUIDs)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        print("Discovered \(peripheral.name) at \(RSSI)")
        
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            
            print("Connecting to peripheral \(peripheral)")
            
            centralManager?.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        print("Failed to connect to \(peripheral). (\(error.localizedDescription))")
        
        cleanup()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        print("Peripheral Connected")
        
        centralManager?.stopScan()
        print("Scan stopped")
        
        data.length = 0;
        
        peripheral.delegate = self
        
        peripheral.discoverServices([serviceUUIDs])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if let error = error{
            print("Error discovering service: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        for service in peripheral.services as! [CBService]{
            peripheral.discoverCharacteristics([CharacteristicUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if let error = error{
            print("Error discovering service: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        for Characteristic in service.characteristics as! [CBCharacteristic]{
            if Characteristic.UUID.isEqual(CharacteristicUUID) {
                
                peripheral.setNotifyValue(true, forCharacteristic: Characteristic)
            }
        }
        
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if let error = error{
            print("Error discovering service: \(error.localizedDescription)")
            return
        }
        
        if let stringFromData = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding){
            if stringFromData.isEqualToString("EOM") {
                
                receivedData = NSString(data: (data.copy() as! NSData) as NSData, encoding: NSUTF8StringEncoding) as! String
                
                print(receivedData)
                
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                
                centralManager?.cancelPeripheralConnection(peripheral)
            }
            
            data.appendData(characteristic.value)
            
            print("Received: \(stringFromData)")
        } else {
            print("Invalid Data")
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        print("Error changing notification state: \(error?.localizedDescription)")
        
        if !characteristic.UUID.isEqual(CharacteristicUUID){
            return
        }
        
        if(characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
            
        } else {
            print("Notification stopped on (\(characteristic))  Disconnecting")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        print("Peripheral Disconnected")
        discoveredPeripheral = nil
        
        scan()
    }
    
    func cleanup() {
        if discoveredPeripheral?.state != CBPeripheralState.Connected{
            return
        }
        
        if let services = discoveredPeripheral?.services as? [CBService] {
            for service in services {
                if let characteristics = service.characteristics as? [CBCharacteristic] {
                    for characteristic in characteristics {
                        if characteristic.UUID.isEqual(CharacteristicUUID) && characteristic.isNotifying {
                            discoveredPeripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                        }
                    }
                }
            }
            
        }
        
    }

}


