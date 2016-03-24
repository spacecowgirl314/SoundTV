//
//  NowPlayingViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import SDWebImage

class NowPlayingArtworkButton: UIButton {
    weak var owner: NowPlayingViewController?
    
    var touchesHaveMoved = false
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touchesHaveMoved = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        touchesHaveMoved = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touchesHaveMoved == false {
            owner?.togglePlayer()
        }
    }
}

class NowPlayingViewController: UIViewController, SharedAudioPlayerDelegate {
    @IBOutlet var artworkButton : NowPlayingArtworkButton!
    @IBOutlet var artistLabel : UILabel!
    @IBOutlet var trackLabel : UILabel!
    @IBOutlet var elapsedLabel : UILabel!
    @IBOutlet var timeLeftLabel : UILabel!
    @IBOutlet var progressBar : UIProgressView!
    
    @IBOutlet var artworkWidthConstraint : NSLayoutConstraint!
    @IBOutlet var artworkHeightConstraint : NSLayoutConstraint!
    @IBOutlet var artistLabelWidthConstraint : NSLayoutConstraint!
    @IBOutlet var trackLabelWidthConstraint : NSLayoutConstraint!
    
    @IBOutlet var vibrancyImageView : UIImageView!
    
    @IBOutlet var likeButton : UIButton!
    
    let player = SharedAudioPlayer.sharedPlayer
    var interval : Double?
    var isShowingOptions = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        SharedAudioPlayer.sharedPlayer.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.artworkButton.owner = self
        SharedAudioPlayer.sharedPlayer.delegate = self
        
        // clear out the placement text
        artistLabel.text = ""
        trackLabel.text = ""
        elapsedLabel.text = "--:--"
        timeLeftLabel.text = "--:--"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NowPlayingViewController.updateNowPlaying), name: "SharedPlayerDidFinishObject", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NowPlayingViewController.syncScrubber), name: "SharedAudioPlayerUpdatedTimePlayed", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SharedAudioPlayer.sharedPlayer.delegate = self
        self.updateNowPlaying()
        
        if animated {
            vibrancyImageView.alpha = 0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if animated {
            UIView.animateWithDuration(1) {
                self.vibrancyImageView.alpha = 1
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if animated {
            vibrancyImageView.alpha = 0
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        isShowingOptions = true
        self.revealOptions()
    }
    
    func currentItem() -> SoundCloudTrack? {
        switch player.sourceType {
        case .Stream:
            if player.streamItems.count < 1 {
                return nil
            }
            return player.streamItems[player.positionInPlaylist] as? SoundCloudTrack
        case .Favorites:
            if player.favoriteItems.count < 1 {
                return nil
            }
            return player.favoriteItems[player.positionInPlaylist] as? SoundCloudTrack
        case .User:
            if player.userItems.count < 1 {
                return nil
            }
            return player.userItems[player.positionInPlaylist] as? SoundCloudTrack
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
            vibrancyImageView.sd_setImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")), completed: { (image, error, cacheType, url) -> Void in
                let newSize = CGSize(width: image.size.width/3, height: image.size.height/3)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                image.drawAtPoint(CGPoint(x: -(image.size.width/2-newSize.width/2), y: -(image.size.height/2-newSize.height/2)))
                let newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.vibrancyImageView.image = newImage
            })
            
            if let isFavorited = item.userFavorite {
                if isFavorited == 1 {
                    likeButton.setTitle(NSLocalizedString("like.remove", comment: "Unlike"), forState: .Normal)
                }
                else {
                    likeButton.setTitle(NSLocalizedString("like", comment: "Like"), forState: .Normal)
                }
            }
            
            // this is important, if we don't do this, it won't set the progress if we're paused and switch to now playing
            self.syncScrubber()
        }
    }
    
    func timeInterval() -> Double {
        var interval = 0.1
        
        let playerDuration = self.playerItemDuration()
        let duration = CMTimeGetSeconds(playerDuration);
        if isfinite(duration)
        {
            let width = CGRectGetWidth(progressBar.bounds);
            interval = 0.5 * duration / Double(width);
        }
        
        return interval
    }
    
    func playerItemDuration() -> CMTime
    {
        guard let audioPlayer = player.audioPlayer else {
            return kCMTimeInvalid
        }
        
        if let thePlayerItem = audioPlayer.currentItem {
            if thePlayerItem.status == .ReadyToPlay
            {
                return audioPlayer.currentItem!.duration
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
        if CMTIME_IS_INVALID(playerDuration)
        {
            progressBar.progress = 0
            elapsedLabel.text = "--:--"
            timeLeftLabel.text = "--:--"
            return
        }
        
        let duration : Float64 = CMTimeGetSeconds(playerDuration);
        if isfinite(duration) && duration > 0
        {
            let minValue : Float64 = 0.0
            let maxValue : Float64 = 1.0
            let time = CMTimeGetSeconds(player.audioPlayer!.currentTime());
            progressBar.progress = Float((maxValue - minValue) * time / duration + minValue)
            
            elapsedLabel.text = formatTime(player.audioPlayer!.currentTime())
            timeLeftLabel.text = "-\(formatTime(self.playerItemDuration()-player.audioPlayer!.currentTime()))"
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
                    // reflect favorite immediately, will change back upon error
                    item.userFavorite = 1
                    self.likeButton.setTitle(NSLocalizedString("like.remove", comment: "Unlike"), forState: .Normal)
                    SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                        if error == nil {
                            print("saved favorite")
                        }
                        else {
                            // revert title upon failure
                            item.userFavorite = 0
                            self.likeButton.setTitle(NSLocalizedString("like", comment: "Like"), forState: .Normal)
                        }
                    })
                }
                // FIXME: This requires factoring in that favorites can be removed from the stream and this can cause problems
                // Whereas the unlikelihood of a song being removed from the main stream and causing problems is
                // incredibly low, removing a song here will cause it not to reflect in the favorites.
                // This is behavior that would be expected but since it won't behave as such it's been disabled.
                else {
                    item.userFavorite = 0
                    self.likeButton.setTitle(NSLocalizedString("like", comment: "Like"), forState: .Normal)
                    SoundCloudAPIClient.sharedClient().removeFavoriteWithSongID(item.identifier.stringValue
                        , completion: { (error: NSError?) -> Void in
                        if error == nil {
                            print("removed favorite")
                        }
                        else {
                            item.userFavorite = 1
                            self.likeButton.setTitle(NSLocalizedString("like.remove", comment: "Unike"), forState: .Normal)
                        }
                    })
                }
            }
            else {
                item.userFavorite = 1
                self.likeButton.setTitle(NSLocalizedString("like.remove", comment: "Unlike"), forState: .Normal)
                SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                    if error == nil {
                        print("saved favorite")
                    }
                    else {
                        item.userFavorite = 0
                        self.likeButton.setTitle(NSLocalizedString("like", comment: "Like"), forState: .Normal)
                    }
                })
            }
        }
    }
}

