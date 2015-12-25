//
//  TrackItemView.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/13/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class TrackItemView : UICollectionViewCell {
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var artistLabel : UILabel!
    @IBOutlet var trackLabel : UILabel!
    @IBOutlet var topSpaceConstraint : NSLayoutConstraint!
    @IBOutlet var artistWidthConstraint : NSLayoutConstraint!
    @IBOutlet var trackWidthConstraint : NSLayoutConstraint!
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        // this is essentially one big that hack that is necessary because of private APIs
        if (context.nextFocusedView == self) {
            // move labels below image view
            self.topSpaceConstraint.constant += 32
            // increase width of labels
            self.artistWidthConstraint.constant += 60
            self.trackWidthConstraint.constant += 60
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layoutIfNeeded()
                self.artistLabel.textColor = UIColor.whiteColor()
                self.trackLabel.textColor = UIColor.whiteColor()
                self.artistLabel.layer.shadowColor = UIColor.blackColor().CGColor
                self.artistLabel.layer.shadowOffset = CGSize(width: 1,height: 1)
                self.artistLabel.layer.shadowOpacity = 0.5;
                self.artistLabel.layer.shadowRadius = 1;
                self.trackLabel.layer.shadowColor = UIColor.blackColor().CGColor
                self.trackLabel.layer.shadowOffset = CGSize(width: 1,height: 1)
                self.trackLabel.layer.shadowOpacity = 0.5;
                self.trackLabel.layer.shadowRadius = 1;
                }, completion: { () -> Void in
                    
            })
        }
        else {
            // put the labels back
            self.topSpaceConstraint.constant -= 32
            // put the width back
            self.artistWidthConstraint.constant -= 60
            self.trackWidthConstraint.constant -= 60
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.layoutIfNeeded()
                self.artistLabel.textColor = UIColor.darkGrayColor()
                self.trackLabel.textColor = UIColor.blackColor()
                self.artistLabel.layer.shadowColor = UIColor.clearColor().CGColor
                self.trackLabel.layer.shadowColor = UIColor.clearColor().CGColor
                }, completion: { () -> Void in
                    
            })
        }
    }
}
