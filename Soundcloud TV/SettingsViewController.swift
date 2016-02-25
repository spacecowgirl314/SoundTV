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
    @IBOutlet var versionLabel : UILabel!
    
    override func viewDidLoad() {
        if let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String, shortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "v\(shortVersion)(\(bundleVersion))"
        }
        iconView.layer.cornerRadius = 9.0
        iconView.layer.masksToBounds = true
    }
    
    @IBAction func logout() {
        SoundCloudAPIClient.sharedClient().logout()
    }
}

