//
//  MainTabBarController.swift
//  Tinstagram
//
//  Created by Thanh Pham on 9/9/15.
//  Copyright (c) 2015 Thanh Pham. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var currentUser: PFUser!{
        didSet{
            println("hello \(self.currentUser.username)")
        }
    }
    
}
