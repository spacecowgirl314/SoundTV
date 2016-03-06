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

class ItemViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    var isLoadingMore = false
    var isReloading = false
    var items: [AnyObject] {
        get { fatalError("Subclasses must pick where items come from.") }
    }
    var playerSourceType: CurrentSourceType? {
        get { fatalError("Subclasses must pick where items come from.") }
    }
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let unreachableLabel = UILabel()
    let player = SharedAudioPlayer.sharedPlayer
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openContextMenu:")
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.delegate = self
        self.collectionView!.addGestureRecognizer(longPressGestureRecognizer)
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openContextMenu(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        guard let collectionView = self.collectionView else { return }
        
        var indexPath: NSIndexPath?
        
        for cell in collectionView.visibleCells() {
            if cell.focused {
                indexPath = self.collectionView?.indexPathForCell(cell)
                break
            }
        }
        
        guard let index = indexPath else { return }
        
        guard let item = self.items[index.row] as? SoundCloudTrack else { return }
        
        let actionSheet = UIAlertController(title: item.title, message: item.user.username, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Go to Artist", style: .Default, handler: { (action: UIAlertAction) -> Void in
            // open view controller with artist info for index.row
            let identifier = item.user.identifier
            // remove all previous objects because user items go away (model view) and then change
            SharedAudioPlayer.sharedPlayer.userItems.removeAll()
            print("identifier:\(identifier)")
            SoundCloudAPIClient.sharedClient().getUserSongs("\(identifier)")
            if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("User") as? UserViewController {
                self.presentViewController(viewController, animated: false, completion: nil)
            }
        }))
        
        var likeActionTitle : String?
        if let isFavorited = item.userFavorite {
            if isFavorited == 1 {
                likeActionTitle = NSLocalizedString("like.remove", comment: "Unlike")
            }
            else {
                likeActionTitle = NSLocalizedString("like", comment: "Like")
            }
        }
        
        actionSheet.addAction(UIAlertAction(title: likeActionTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
            if let isFavorited = item.userFavorite {
                if isFavorited != 1 {
                    // reflect favorite immediately, will change back upon error
                    item.userFavorite = 1
                    SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                        if error == nil {
                            print("saved favorite")
                        }
                        else {
                            // revert title upon failure
                            item.userFavorite = 0
                        }
                    })
                }
                    // FIXME: This requires factoring in that favorites can be removed from the stream and this can cause problems
                    // Whereas the unlikelihood of a song being removed from the main stream and causing problems is
                    // incredibly low, removing a song here will cause it not to reflect in the favorites.
                    // This is behavior that would be expected but since it won't behave as such it's been disabled.
                else {
                    item.userFavorite = 0
                    SoundCloudAPIClient.sharedClient().removeFavoriteWithSongID(item.identifier.stringValue
                        , completion: { (error: NSError?) -> Void in
                            if error == nil {
                                print("removed favorite")
                            }
                            else {
                                item.userFavorite = 1
                            }
                    })
                }
            }
            else {
                item.userFavorite = 1
                SoundCloudAPIClient.sharedClient().saveFavoriteWithSongID(item.identifier.stringValue, completion: { (error: NSError?) -> Void in
                    if error == nil {
                        print("saved favorite")
                    }
                    else {
                        item.userFavorite = 0
                    }
                })
            }
        }))
        // this could also double as a follow button for following users that were reposted
//        actionSheet.addAction(UIAlertAction(title: "Unfollow", style: .Destructive, handler: { (action: UIAlertAction) -> Void in
//        }))
        actionSheet.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action: UIAlertAction) -> Void in
            return
        }))
        self.presentViewController(actionSheet, animated: true, completion: { () -> Void in
            return
        })
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collection item selected")
        if let item = items[indexPath.row] as? SoundCloudTrack {
            if item.streamable == true {
                if let playerSourceType = self.playerSourceType {
                    SharedAudioPlayer.sharedPlayer.sourceType = playerSourceType
                }
                self.activityView.startAnimating()
                player.jumpToItemAtIndex(indexPath.row)
                // populate Now Playing Info
                let nowPlaying = MPNowPlayingInfoCenter.defaultCenter()
                nowPlaying.nowPlayingInfo = [MPMediaItemPropertyTitle: item.title, MPMediaItemPropertyPlaybackDuration: item.duration] //MPMediaItemPropertyArtist: itemForView.user.username
                self.activityView.stopAnimating()
                if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlaying") {
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
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

