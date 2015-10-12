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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.objects.append("iPhone")
        self.objects.append("Apple Watch")
        self.objects.append("Mac")
        
        self.youObjects.append("iPhone2")
        self.youObjects.append("Apple Watch2")
        self.youObjects.append("Mac2")
        
        
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
            return self.youObjects.count
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
        let aCell = tableView.dequeueReusableCellWithIdentifier("youActivityCell",
            forIndexPath: indexPath) as! ActivityTableViewCell
        // Sets the text of the Label in the Table View Cell
        aCell.titleLabel.text = self.youObjects[indexPath.row]
        return aCell
        }
    }

    

}
