//
//  SearchViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 10/13/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var results = [PFObject]()
    var selectedUser:PFUser?
    
    
    @IBOutlet weak var searchTerm: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchResult: UITableView!
    @IBAction func Search(sender: UIButton) {
        if searchTerm.text != ""{
            var userSearch = searchTerm.text as String
            var userQuery = PFQuery(className: "_User")
            userQuery.whereKey("username", containsString: userSearch)
            self.results = userQuery.findObjects() as! [PFObject]
            println(results)
            searchResult.reloadData()
        }
        
    }
    
    @IBAction func segmentControl(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            self.searchTerm.hidden = false
            self.searchResult.hidden = false
            self.searchButton.hidden = false
            //searchResult.reloadData()
        case 1:
            self.searchTerm.hidden = true
            self.searchResult.hidden = true
            self.searchButton.hidden = true
        default:
            break
        }
    }
    
    @IBAction func chooseUser(sender: UIButton) {
        selectedUser = results[sender.tag] as? PFUser
        println("@IBAction func chooseUser \(selectedUser)")
        performSegueWithIdentifier("showuser", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResult.dataSource = self
        searchResult.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchresult") as! SearchResultCell
        cell.username.setTitle(results[indexPath.row]["username"] as? String, forState: UIControlState.Normal)
        cell.username.tag = indexPath.row
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
                case "showuser":
                    if let userProfileController = segue.destinationViewController as? ProfileViewController{
                        if let theSender = sender as? SearchViewController{
                            userProfileController.currentUser = PFUser.currentUser()
                            userProfileController.viewUser  = self.selectedUser
                            println("override func prepareForSegue \(self.selectedUser)")
                        }
                }
                default:break
            }
        }
    }
    

}

class SearchResultCell: UITableViewCell{
    
    @IBOutlet weak var username: UIButton!
}