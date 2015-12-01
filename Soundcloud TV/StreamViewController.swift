//
//  SecondViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import MediaPlayer
import SoundCloud
import SDWebImage

class StreamViewController: UICollectionViewController {
    let player = SharedAudioPlayer.sharedPlayer()
    let playerSession = AVAudioSession.sharedInstance()
    var isLoadingMore = false
    var isClosing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.remembersLastFocusedIndexPath = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "SoundCloudAPIClientDidLoadSongs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failed", name: "SoundCloudAPIClientDidFailToLoadSongs", object: nil)
    }
    
    func failed() {
        isLoadingMore = false
    }

    func reload() {
        isLoadingMore = false
        self.collectionView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        if player.streamItemsToShowInTableView.count < 1 {
            if SoundCloudAPIClient.sharedClient().isLoggedIn() {
                SoundCloudAPIClient.sharedClient().getInitialStreamSongs()
            }
            else {
                // if we close the authentication view by hitting the menu button without auth, kill the app
                if isClosing {
                    exit(0)
                }
                self.performSegueWithIdentifier("setup", sender: nil)
                isClosing = true
            }
        }
        else {
            // insert new items if available
//            SoundCloudAPIClient.sharedClient().reloadStream()
//            SoundCloudAPIClient.sharedClient().getFutureStreamSongs()
        }
        do {
            try playerSession.setCategory(AVAudioSessionCategoryPlayback) // TODO: mix in
            try playerSession.setActive(true, withOptions: .NotifyOthersOnDeactivation)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: nil)
        }
        catch {
            
        }
    }
    
    func audioSessionInterrupted(notification: NSNotification) {
        let interruptionTypeAsObject =
        notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        let interruptionType = AVAudioSessionInterruptionType(rawValue:
            interruptionTypeAsObject.unsignedLongValue)
        
        if let type = interruptionType{
            if type == .Began{
                player.audioPlayer.pause()
            }
            if type == .Ended{
                player.audioPlayer.play()
                /* resume the audio if needed */
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collection item selected")
        if let item = player.streamItemsToShowInTableView[indexPath.row] as? SoundCloudTrack {
            if item.streamable == true {
                SharedAudioPlayer.sharedPlayer().sourceType = CurrentSourceTypeStream
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
//                    self.player.jumpToItemAtIndex(indexPath.row)
//                })
                player.jumpToItemAtIndex(indexPath.row)
                // populate Now Playing Info
                let nowPlaying = MPNowPlayingInfoCenter.defaultCenter()
                nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: item.title, MPMediaItemPropertyPlaybackDuration: item.duration] //MPMediaItemPropertyArtist: itemForView.user.username
            }
            else {
                print("can't stream track")
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return player.streamItemsToShowInTableView.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let view = collectionView.dequeueReusableCellWithReuseIdentifier("track", forIndexPath: indexPath) as! TrackItemView
        
        if let item = player.streamItemsToShowInTableView[indexPath.row] as? SoundCloudTrack {
            view.artistLabel.text = item.user.username
            view.trackLabel.text = item.title
            view.imageView.image = nil
            view.imageView.sd_setImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")), placeholderImage: UIImage(named: "Placeholder"))
        }
        else if let item = player.streamItemsToShowInTableView[indexPath.row] as? SoundCloudPlaylist {
            view.artistLabel.text = item.user.username
            view.trackLabel.text = item.title
            view.imageView.image = nil
            view.imageView.sd_setImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")), placeholderImage: UIImage(named: "Placeholder"))
        }
        
        return view
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if collectionView == self.collectionView {
            if let row = context.nextFocusedIndexPath?.row {
                let number = player.streamItemsToShowInTableView.count - row
                print("left: \(number)")
                if player.streamItemsToShowInTableView.count - row <= 4 {
                    if isLoadingMore == false {
                        SharedAudioPlayer.sharedPlayer().getNextStreamSongs()
                    }
                    isLoadingMore = true
                }
            }
        }
    }

    @IBAction func reload(sender: UIButton) {
        SoundCloudAPIClient.sharedClient().reloadStream()
    }
}

