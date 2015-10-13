//
//  BluetoothShareViewController.swift
//  
//
//  Created by Young Woo Jung on 13/10/2015.
//
//

import UIKit
import CoreBluetooth

class BluetoothShareViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {

    var receivedimage : UIImage?

    @IBOutlet weak var imageview: UIImageView!
    
    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    let serviceUUIDs = CBUUID(string: "28ae3a66-3a12-4758-8be5-4e0e5b0136b4")
    let CharacteristicUUID = CBUUID(string: "8cb2fced-e285-4a3d-8798-7587e8fe53d7")
    
    let data = NSMutableData()
    var receivedData : NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        scan()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                receivedData = NSData(data: data)
                receivedimage = UIImage(data: receivedData!)
                imageview.image = receivedimage
                imageview.contentMode = UIViewContentMode.ScaleAspectFit
                
                
                
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                
                centralManager?.cancelPeripheralConnection(peripheral)
            }
            
            data.appendData(characteristic.value)
            let datastring = NSString(data: characteristic.value, encoding: NSASCIIStringEncoding)
            print("Received: \(datastring)")
        } else {
            println("Invalid Data")
            data.appendData(characteristic.value)
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
