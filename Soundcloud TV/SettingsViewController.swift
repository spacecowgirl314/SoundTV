//
//  SettingsViewController.swift
//  SoundCloud TV
//
//  Created by Chloe Stars on 11/15/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    @IBOutlet var iconView : UIImageView!
    
    override func viewDidLoad() {
        iconView.layer.cornerRadius = 9.0
        iconView.layer.masksToBounds = true
    }
    
    @IBAction func logout() {
        SoundCloudAPIClient.sharedClient().logout()
        self.tabBarController?.selectedIndex = 0
    }
}

