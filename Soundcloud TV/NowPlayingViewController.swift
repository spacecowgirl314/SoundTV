//
//  NowPlayingViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import SDWebImage

class NowPlayingViewController: UIViewController {
    @IBOutlet var artworkButton : UIButton!
    @IBOutlet var artistLabel : UILabel!
    @IBOutlet var trackLabel : UILabel!
    @IBOutlet var progressBar : UIProgressView!
    @IBOutlet var elapsedLabel : UILabel!
    @IBOutlet var timeLeftLabel : UILabel!
    
    @IBOutlet var artworkWidthConstraint : NSLayoutConstraint!
    @IBOutlet var artworkHeightConstraint : NSLayoutConstraint!
    @IBOutlet var artistLabelWidthConstraint : NSLayoutConstraint!
    @IBOutlet var trackLabelWidthConstraint : NSLayoutConstraint!
    
    @IBOutlet var vibrancyView : UIVisualEffectView!
    @IBOutlet var vibrancyImageView : UIImageView!
    
    @IBOutlet var likeButton : UIButton!
    
    let player = SharedAudioPlayer.sharedPlayer()
    var isShowingOptions = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNowPlaying", name: "SharedPlayerDidFinishObject", object: nil)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
//        tapRecognizer.delegate = self
//        let pressType = UIPressType.Select
//        tapRecognizer.allowedPressTypes = [NSNumber(integer: pressType.rawValue)];
//        tapRecognizer.allowedTouchTypes = [NSNumber(integer: pressType.rawValue)];
//        self.view.addGestureRecognizer(tapRecognizer)
        
        // clear out the placement text
        artistLabel.text = ""
        trackLabel.text = ""
        elapsedLabel.text = "--:--"
        timeLeftLabel.text = "--:--"
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateNowPlaying()
    }
    
    override func viewDidDisappear(animated: Bool) {
        isShowingOptions = true
        self.revealOptions()
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .Began {
            print("animate")
        }
    }
    
    func currentItem() -> SoundCloudTrack? {
        switch player.sourceType {
        case CurrentSourceTypeStream:
            if player.streamItemsToShowInTableView.count < 1 {
                return nil
            }
            return player.streamItemsToShowInTableView[player.positionInPlaylist] as? SoundCloudTrack
        case CurrentSourceTypeFavorites:
            if player.favoriteItemsToShowInTableView.count < 1 {
                return nil
            }
            return player.favoriteItemsToShowInTableView[player.positionInPlaylist] as? SoundCloudTrack
        default:
            return nil
        }
    }
    
    func updateNowPlaying() {
        if let item = self.currentItem() {
            artistLabel.text = item.user.username
            trackLabel.text = item.title
            
            artworkButton.layer.shadowColor = UIColor.blackColor().CGColor
            artworkButton.layer.shadowOffset = CGSizeMake(0, 1)
            artworkButton.layer.shadowOpacity = 1
            artworkButton.layer.shadowRadius = 3.0
            artworkButton.clipsToBounds = false
            artworkButton.contentMode = .ScaleAspectFill
            artworkButton.sd_setBackgroundImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")), forState: .Normal, placeholderImage: UIImage(named: "Placeholder"))
//            vibrancyImageView.sd_setImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")))
            
            if let isFavorited = item.userFavorite {
                if isFavorited == 1 {
                    likeButton.setTitle("Liked", forState: .Normal)
                }
                else {
                    likeButton.setTitle("Like", forState: .Normal)
                }
            }
            
            // setup playback progress bar indicator
            var interval = 0.1
            
            let playerDuration = self.playerItemDuration()
            if (CMTIME_IS_INVALID(playerDuration))
            {
                return
            }
            let duration = CMTimeGetSeconds(playerDuration);
            if (isfinite(duration))
            {
                let width = CGRectGetWidth(progressBar.bounds);
                interval = 0.5 * duration / Double(width);
            }
            
            player.audioPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)), queue: nil) { (time: CMTime) -> Void in
                self.syncScrubber()
            }
        }
    }
    
    func playerItemDuration() -> CMTime
    {
        if let thePlayerItem = player.audioPlayer.currentItem {
            if thePlayerItem.status == .ReadyToPlay
            {
                return player.audioPlayer.currentItem!.duration
            }
        }
        
        return kCMTimeInvalid
    }
    
    func formatTime(time: CMTime) -> String {
        let date = NSDate(timeIntervalSince1970: CMTimeGetSeconds(time))
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        // only show hours if necessary
        if CMTimeGetSeconds(time)/60/60 >= 1 {
            dateFormatter.dateFormat = "HH:mm:ss"
        }
        else {
            dateFormatter.dateFormat = "mm:ss"
        }
        return dateFormatter.stringFromDate(date)
    }
    
    func syncScrubber() {
        let playerDuration = self.playerItemDuration()
        if (CMTIME_IS_INVALID(playerDuration))
        {
            progressBar.progress = 0
            elapsedLabel.text = "--:--"
            timeLeftLabel.text = "--:--"
            return
        }
        
        let duration : Float64 = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration) && (duration > 0))
        {
            let minValue : Float64 = 0.0
            let maxValue : Float64 = 1.0
            let time = CMTimeGetSeconds(player.audioPlayer.currentTime());
            progressBar.progress = Float((maxValue - minValue) * time / duration + minValue)
            
            elapsedLabel.text = formatTime(player.audioPlayer.currentTime())
            timeLeftLabel.text = "-\(formatTime(self.playerItemDuration()-player.audioPlayer.currentTime()))"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func revealOptions() {
        if isShowingOptions {
            self.artworkWidthConstraint.constant = 500
            self.artworkHeightConstraint.constant = 500
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.likeButton.alpha = 0.0
                }) { (nothing: Bool) -> Void in
                    
            }
            
            isShowingOptions = false
        }
        else {
            self.artworkWidthConstraint.constant = 400
            self.artworkHeightConstraint.constant = 400
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.likeButton.alpha = 1.0
                }) { (nothing: Bool) -> Void in
                    
            }
            
            isShowingOptions = true
        }
    }
    
    @IBAction func togglePlayer() {
        self.revealOptions()
    }
    
    @IBAction func favoriteTrack() {
        if let item = self.currentItem() {
            if let isFavorited = item.userFavorite {
                if isFavorited != 1 {
                    SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                        if error == nil {
                            print("saved favorite")
                            item.userFavorite = 1
                            self.likeButton.setTitle("Liked", forState: .Normal)
                        }
                    })
                }
                // FIXME: This requires factoring in that favorites can be removed from the stream and this can cause problems
                // Whereas the unlikelihood of a song being removed from the main stream and causing problems is
                // incredibly low, removing a song here will cause it not to reflect in the favorites.
                // This is behavior that would be expected but since it won't behave as such it's been disabled.
                else {
                    SoundCloudAPIClient.sharedClient().removeFavoriteWithSongID(item.identifier.stringValue
                        , completion: { (error: NSError?) -> Void in
                        if error == nil {
                            print("removed favorite")
                            item.userFavorite = 0
                            self.likeButton.setTitle("Like", forState: .Normal)
                        }
                    })
                }
            }
            else {
                SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                    if error == nil {
                        print("saved favorite")
                        item.userFavorite = 1
                        self.likeButton.setTitle("Liked", forState: .Normal)
                    }
                })
            }
        }
    }

}

