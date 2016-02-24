//
//  ItemViewController.swift
//  Sound TV
//
//  Created by Chloe Stars on 2/6/16.
//  Copyright © 2016 Chloe Stars. All rights reserved.
//

import UIKit
import MediaPlayer
import SoundCloud

class ItemViewController: UICollectionViewController {
    var isLoadingMore = false
    var isReloading = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.remembersLastFocusedIndexPath = true
        
        activityView.color = UIColor.blackColor()
        activityView.frame = CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: activityView.frame.width, height: activityView.frame.height)
        activityView.hidesWhenStopped = true
        self.view.addSubview(activityView)
        
        unreachableLabel.text = NSLocalizedString("Loading Error", comment: "unreachable")
        unreachableLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        unreachableLabel.hidden = true
        unreachableLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        unreachableLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(unreachableLabel)
        
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
        if !isReloading {
            self.activityView.stopAnimating()
        }
        isReloading = false
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
                self.activityView.startAnimating()
                self.getInitial()
            }
        }
        
        do {
            try playerSession.setCategory(AVAudioSessionCategoryPlayback) // TODO: mix in
            try playerSession.setActive(true, withOptions: .NotifyOthersOnDeactivation)
        }
        catch {
            
        }
    }
    
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
                self.activityView.startAnimating()
                player.jumpToItemAtIndex(indexPath.row)
                // populate Now Playing Info
                let nowPlaying = MPNowPlayingInfoCenter.defaultCenter()
                nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: item.title, MPMediaItemPropertyPlaybackDuration: item.duration] //MPMediaItemPropertyArtist: itemForView.user.username
                self.activityView.stopAnimating()
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
                // reached the bottom of the stream, start loading more
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
        self.isReloading = true
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

