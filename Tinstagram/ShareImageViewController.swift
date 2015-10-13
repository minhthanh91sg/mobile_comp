//
//  ShareImageViewController.swift
//  Tinstagram
//
//  Created by Matheu Malo on 8/10/2015.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit
import CoreBluetooth

class ShareImageViewController: UIViewController, UITextFieldDelegate, CBPeripheralManagerDelegate {

    // MARK: - Properties
    
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: NSData?
    var sendDataIndex: Int?
    let serviceUUIDs = CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")
    let serviceUUID:[AnyObject] = [CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")]
    let CharacteristicUUID = CBUUID(string: "8cb2fced-e285-4a3d-8798-7587e8fe53d7")
    var sendingEOM = false;
    let NOTIFY_MTU = 20


    
    @IBOutlet weak var editedImageDisplay: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    /* Image received from ImageEffectViewController */
    var imageReceived: UIImage!
    
    /* Limit of characters for comment */
    let textFieldCharLimit = 144
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads the received image from CImageEffectViewController
        editedImageDisplay.image = imageReceived
        
        //textField delegate
        textField.delegate = self
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        leftSwipe.direction = .Left
        
        view.addGestureRecognizer(leftSwipe)
        
        
        // Do any additional setup after loading the view.
    }
    
    func swipe(sender : UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            print("Swiped")
            
            let actionSheetController : UIAlertController = UIAlertController(title: "Bluetooth Range", message: "This post will be shared", preferredStyle: .ActionSheet)
            
            let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            actionSheetController.addAction(cancelAction)
            
            let SendAction : UIAlertAction = UIAlertAction(title: "Share", style: .Default, handler : {_ in self.start()})
            
            actionSheetController.addAction(SendAction)
            
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            
            
        }
    }
    
    func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        
        println("Started")
        println(error)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        peripheralManager?.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        print(peripheral.state)
        
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            return
        }
        
        println("powered on")
        
        transferCharacteristic = CBMutableCharacteristic(type: CharacteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        
        let transferService = CBMutableService(type: serviceUUIDs, primary: true)
        
        transferService.characteristics = [transferCharacteristic!]
        
        peripheralManager!.addService(transferService)
        
        peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [serviceUUIDs]])
        println("Start Advertising")
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        println("central subscribed to characteristic")
        dataToSend = UIImageJPEGRepresentation(imageReceived, 0.1)
        sendDataIndex = 0
        
        sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        
        print("central unsubscribed to characteristic")
        peripheralManager!.stopAdvertising()
        
    }
    
    func sendData() {
        if sendingEOM {
            let didSend = peripheralManager?.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if (didSend == true) {
                sendingEOM = false
                
                print("Sent : EOM")
            }
            
            return
        }
        
        if(sendDataIndex >= dataToSend?.length) {
            return
        }
        
        var didSend = true
        
        while didSend {
            
            var amountToSend = dataToSend!.length - sendDataIndex!
            println(amountToSend)
            
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU
            }
            
            
            let chunk = NSData(bytes: dataToSend!.bytes + sendDataIndex!, length: amountToSend)
            
            didSend = peripheralManager!.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if (!didSend) {
                return
            }
            
            let stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            
            println("sent : \(stringFromData)")
            
            sendDataIndex! += amountToSend
            
            if (sendDataIndex >= dataToSend!.length) {
                
                sendingEOM = true
                
                var eomSent = peripheralManager!.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                
                if(eomSent) {
                    
                    sendingEOM = false
                    print("Sent : EOM")
                }
                return
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        
        sendData()
    }
        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    /* Sends photo to parse backend */
    @IBAction func shareButton(sender: AnyObject) {
        let imageData = UIImageJPEGRepresentation(self.imageReceived, 0.5) //image compression
        let imageFile = PFFile(data: imageData)
        var currentUser = PFUser.currentUser()?.objectId
        var userImage = PFObject(className: "Image")
        var likes = 0
        var comments = 0
        var description = textField.text
        
        userImage["image"] = imageFile
        userImage["userId"] = currentUser
        userImage["likes"] = likes
        userImage["comments"] = comments
        userImage["description"] = description
        userImage.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("object was saved")
                
            } else {
                // There was a problem, check error.description
                println("Object not saved")
            }
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        editedImageDisplay.image = nil
        description = nil
        
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewControllerAnimated(true)

        
        //UIImageWriteToSavedPhotosAlbum(self.imageReceived, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
        
    }

    
    // MARK: Delegates
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("Allow editing")
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        println("User is editing text")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("User done editing text")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Enter was pressed")
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var length = count(textField.text) + count(string)
        
        if (length > textFieldCharLimit) {
            return false
        }
        else {return true}
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    
    
   

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
