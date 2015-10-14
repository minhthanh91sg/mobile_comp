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
    var suggestions = [PFObject]()
    var selectedUser:PFUser?
    
    @IBOutlet weak var suggestResult: UITableView!
    
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
            self.suggestResult.hidden = true
        case 1:
            self.searchTerm.hidden = true
            self.searchResult.hidden = true
            self.searchButton.hidden = true
            self.suggestResult.hidden = false
        default:
            break
        }
    }
    
    @IBAction func chooseSuggestion(sender: UIButton) {
        selectedUser = suggestions[sender.tag] as? PFUser
        println("@IBAction func chooseUser \(selectedUser)")
        performSegueWithIdentifier("showuser", sender: self)
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
        suggestResult.dataSource = self
        suggestResult.delegate = self
        findSuggestions()
    }
    
    func findSuggestions() -> Void{
        var query1 = PFQuery(className: "_User")
        //var currentUser = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()!.objectId)
        
        //var followingUsers = [String]()
        
        if let followingUserArrayString = PFUser.currentUser()!["following"] as? [String] {
            //println(followingUsers)
            query1.whereKey("objectId", notContainedIn: followingUserArrayString)
            query1.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
            query1.limit = 10
            var query1Results = query1.findObjects() as! [PFObject]
            if query1Results != [] {
                for query1Result in query1Results{
                    suggestions.append(query1Result)
                }
            }

        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchResult{
            return results.count
        }else if tableView == self.suggestResult{
            return suggestions.count
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.searchResult{
            let cell = tableView.dequeueReusableCellWithIdentifier("searchresult") as! SearchResultCell
            cell.username.setTitle(results[indexPath.row]["username"] as? String, forState: UIControlState.Normal)
            cell.username.tag = indexPath.row
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("suggestresult") as! SearchResultCell
            cell.username.setTitle(suggestions[indexPath.row]["username"] as? String, forState: UIControlState.Normal)
            cell.username.tag = indexPath.row
            return cell
        }
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