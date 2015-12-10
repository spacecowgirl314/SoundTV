//
//  AcknowledgementsViewController.swift
//  Sound TV
//
//  Created by Chloe Stars on 12/9/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class AcknowledgementsViewController : UIViewController {
    
    @IBOutlet var acknowledgementsView : UIScrollView!
    override weak var preferredFocusedView: UIView? { return self.acknowledgementsView }
    
    override func viewDidLoad() {
        let touchType = UITouchType.Indirect
        
        acknowledgementsView.userInteractionEnabled = true
        acknowledgementsView.panGestureRecognizer.allowedTouchTypes = [NSNumber(integer: touchType.rawValue)];
    }
}

class ScrollableTextView : UITextView {
    override func canBecomeFocused() -> Bool {
        return true
    }
}