//
//  TabBarController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/14/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesEnded(presses, withEvent: event)
        for item in presses {
            if item.type == .PlayPause {
                SharedAudioPlayer.sharedPlayer.togglePlayPause()
            }
        }
    }
}