//
//  AuthenticationViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import SoundCloud

class AuthenticationViewController: UIViewController {
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dismissViewController"), name: SCSoundCloudAccountDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didFailToAuthenticate"), name: SCSoundCloudDidFailToRequestAccessNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func authenticate(sender: UIButton) {
        SCSoundCloud.requestAccessWithUsername(usernameField.text, password: passwordField.text)
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFailToAuthenticate() {
        // let the user know it failed
        let actionSheetController: UIAlertController = UIAlertController(title: "Error", message: "Failed to authenticate with SoundCloud", preferredStyle: .ActionSheet)

        let dismissAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in }
        actionSheetController.addAction(dismissAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}