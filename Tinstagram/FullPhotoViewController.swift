//
//  FullPhotoViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/8/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit
import CoreBluetooth

class FullPhotoViewController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet weak var fullSizeImage: UIImageView!
    
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: NSData?
    var sendDataIndex: Int?
    let serviceUUIDs = CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")
    let serviceUUID:[AnyObject] = [CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")]
    let CharacteristicUUID = CBUUID(string: "843ddfb6-4355-4250-bae0-167df24161c6")
    var sendingEOM = false;
    let NOTIFY_MTU = 20
    var imageFile: PFFile!
    var imageID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("FullPhotoViewController:::::::\(imageID)")
        println(imageFile)
        imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil{
                    let image = UIImage(data: imageData!)
                    self.fullSizeImage.image = image
                }
        }
        
        fullSizeImage.contentMode = UIViewContentMode.ScaleAspectFit
        
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
        
        print("Started")
        print(error)
        
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
        
        print("powered on")
        
        transferCharacteristic = CBMutableCharacteristic(type: CharacteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        
        let transferService = CBMutableService(type: serviceUUIDs, primary: true)
        
        transferService.characteristics = [transferCharacteristic!]
        
        peripheralManager!.addService(transferService)
        
        peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [serviceUUIDs]])
        print("Start Advertising")
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        print("central subscribed to characteristic")
        dataToSend = imageID.dataUsingEncoding(NSUTF8StringEncoding)
        sendDataIndex = 0
        
        sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        
        print("central unsubscribed to characteristic")
        
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
            
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU
            }
            
            let chunk = NSData(bytes: dataToSend!.bytes + sendDataIndex!, length: amountToSend)
            
            didSend = peripheralManager!.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if (!didSend) {
                return
            }
            
            let stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            
            print("sent : \(stringFromData)")
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
