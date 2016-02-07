//
//  ItemViewController.swift
//  Sound TV
//
//  Created by Chloe Stars on 2/6/16.
//  Copyright © 2016 Chloe Stars. All rights reserved.
//

import UIKit
import MediaPlayer
import ReachabilitySwift
import SoundCloud

class ItemViewController: UICollectionViewController {
    var isLoadingMore = false
    var isClosing = false
    var items: NSMutableArray {
        get { fatalError("Subclasses must pick where items come from.") }
    }
    var playerSourceType: CurrentSourceType? {
        get { fatalError("Subclasses must pick where items come from.") }
    }
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let unreachableLabel = UILabel()
    let player = SharedAudioPlayer.sharedPlayer()
    let playerSession = AVAudioSession.sharedInstance()
    let reachability: Reachability? = try? Reachability.reachabilityForInternetConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.remembersLastFocusedIndexPath = true
        
        activityView.color = UIColor.blackColor()
        activityView.frame = CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: activityView.frame.width, height: activityView.frame.height)
        activityView.hidesWhenStopped = true
        self.view.addSubview(activityView)
        
        
        // TODO: Localize
        unreachableLabel.text = NSLocalizedString("Could not load from SoundCloud.", comment: "Label for network error while loading from SoundCloud.")
        unreachableLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        unreachableLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        self.view.addSubview(unreachableLabel)
        unreachableLabel.translatesAutoresizingMaskIntoConstraints = false
        unreachableLabel.hidden = true
        
        NSLayoutConstraint.activateConstraints([
            unreachableLabel.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor),
            unreachableLabel.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor),
        ])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loaded", name: "SoundCloudAPIClientDidLoadSongs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "failed", name: "SoundCloudAPIClientDidFailToLoadSongs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unreachable", name: "SoundCloudAPIClientIsUnreachable", object: nil)
    }
    
    func failed() {
        isLoadingMore = false
        self.activityView.stopAnimating()
        self.unreachableLabel.hidden = false
    }
    
    func loaded() {
        isLoadingMore = false
        self.activityView.stopAnimating()
        self.collectionView?.reloadData()
        self.unreachableLabel.hidden = true
    }
    
    func unreachable() {
        isLoadingMore = false
        self.activityView.stopAnimating()
        self.unreachableLabel.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        if items.count < 1 {
            if SoundCloudAPIClient.sharedClient().isLoggedIn() {
                self.getInitial()
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
            //            NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: nil)
        }
        catch {
            
        }
    }
    
    //    func audioSessionInterrupted(notification: NSNotification) {
    //        let interruptionTypeAsObject =
    //        notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
    //
    //        let interruptionType = AVAudioSessionInterruptionType(rawValue:
    //            interruptionTypeAsObject.unsignedLongValue)
    //
    //        if let type = interruptionType{
    //            if type == .Began{
    //                player.audioPlayer.pause()
    //            }
    //            if type == .Ended{
    //                player.audioPlayer.play()
    //                /* resume the audio if needed */
    //            }
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collection item selected")
        if let item = items[indexPath.row] as? SoundCloudTrack {
            if item.streamable == true {
                if let playerSourceType = self.playerSourceType {
                    SharedAudioPlayer.sharedPlayer().sourceType = playerSourceType
                }
                player.jumpToItemAtIndex(indexPath.row)
                // populate Now Playing Info
                let nowPlaying = MPNowPlayingInfoCenter.defaultCenter()
                nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: item.title, MPMediaItemPropertyPlaybackDuration: item.duration] //MPMediaItemPropertyArtist: itemForView.user.username
                self.performSegueWithIdentifier("nowPlaying", sender: self)
            }
            else {
                print("can't stream track")
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let view = collectionView.dequeueReusableCellWithReuseIdentifier("track", forIndexPath: indexPath) as! TrackItemView
        
        if let item = items[indexPath.row] as? SoundCloudTrack {
            view.artistLabel.text = item.user.username
            view.trackLabel.text = item.title
            view.imageView.image = nil
            view.imageView.sd_setImageWithURL(NSURL(string: SoundCloudClient.imageURLForItem(item, size: "t500x500")), placeholderImage: UIImage(named: "Placeholder"))
        }
        else if let item = items[indexPath.row] as? SoundCloudPlaylist {
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
            return UICollectionReusableView()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if collectionView == self.collectionView {
            if let row = context.nextFocusedIndexPath?.row {
                if items.count - row <= 4 {
                    if isLoadingMore == false {
                        self.getNext()
                    }
                    isLoadingMore = true
                }
            }
        }
    }
    
    @IBAction func reload(sender: UIButton) {
        self.unreachableLabel.hidden = true
        self.activityView.startAnimating()
        SoundCloudAPIClient.sharedClient().reloadStream()
    }
    
    // Subclass functions
    func getInitial() {
        fatalError("Subclasses must provide the functions for data.")
    }
    
    func getNext() {
        fatalError("Subclasses must provide the functions for data.")
    }
}

