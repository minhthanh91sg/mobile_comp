//
//  ViewController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/5/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var incorrectLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var loggedInUser: PFUser? { didSet {updateUI()}}
    
    @IBAction func signupAccount() {
        spinner.startAnimating()
        var user = PFUser()
        
        user.username = usernameField.text
        user.password = passwordField.text
        user.setObject([], forKey: "following")
        user.setObject([], forKey: "follower")
        user.setObject([], forKey: "post")
        
        if user.username == "" || user.password == ""{
            spinner.stopAnimating()
            self.incorrectLabel.text = "Username and/or Passsword is empty"
            self.incorrectLabel.textColor = UIColor.redColor()
    
        }
        var signedUp: Bool = user.signUp()        
        if signedUp == true{
            
            spinner.stopAnimating()
            self.incorrectLabel.text = "Account successfully created"
                
        }else{
            spinner.stopAnimating()
            self.incorrectLabel.text = "The Username already exists"
            self.incorrectLabel.textColor = UIColor.redColor()
        }
        
    }
    @IBAction func loginAccount() {
        spinner.startAnimating()
        var username = usernameField.text
        var password = passwordField.text
        
        var user: PFUser? = PFUser.logInWithUsername(username, password: password)
        
        if user !=  nil{
            spinner.stopAnimating()
            self.loggedInUser = user
            self.performSegueWithIdentifier("loggedin", sender: self)
        }else{
            spinner.stopAnimating()
            self.incorrectLabel.textColor = UIColor.redColor()
        }
        
    
    
    }
    
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "loggedin" {
            if loggedInUser == nil{
//                let alert = UIAlertView()
//                alert.title = "Alert"
//                alert.message = "Incorrect Username and/or Password"
//                alert.addButtonWithTitle("Ok")
//                alert.show()
                return false
            }
            else{
                return true
            }
        }
        return true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let tabCon = destination as? UITabBarController{
            if let tabViewController = segue.destinationViewController as? MainTabBarController{
                if let identifier = segue.identifier {
                    switch identifier {
                    case "loggedin":
                        if let theSender = sender as? LogInViewController{
                            tabViewController.currentUser = sender?.loggedInUser
                        }
                    default: break
                    }
                }
            }
        }
        
    }
    
    private func updateUI(){
        
    }
    
    override func viewDidLoad(){
        passwordField.secureTextEntry = true
        super.viewDidLoad()
        
    }
    
}

