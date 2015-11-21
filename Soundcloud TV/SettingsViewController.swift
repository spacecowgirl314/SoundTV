//
//  SettingsViewController.swift
//  SoundCloud TV
//
//  Created by Chloe Stars on 11/15/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    @IBOutlet var acknowledgementsView : UIScrollView!
    
    override func viewDidAppear(animated: Bool) {
        let touchType = UITouchType.Indirect
        
        acknowledgementsView.userInteractionEnabled = true
        acknowledgementsView.panGestureRecognizer.allowedTouchTypes = [NSNumber(integer: touchType.rawValue)];
    }
    
    @IBAction func logout() {
        SoundCloudAPIClient.sharedClient().logout()
        self.tabBarController?.selectedIndex = 0
    }
}

class ScrollableScrollView : UITextView {
    override func canBecomeFocused() -> Bool {
        return true
    }
}