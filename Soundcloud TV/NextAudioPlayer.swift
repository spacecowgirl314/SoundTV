//
//  NextAudioPlayer.swift
//  Sound TV
//
//  Created by Chloe Stars on 3/1/16.
//  Copyright © 2016 Chloe Stars. All rights reserved.
//

import Foundation
import AVFoundation

enum CurrentSourceType: Int {
    case Stream
    case Favorites
    case User
}

class SharedAudioPlayer: NSObject, AVAudioPlayerDelegate {
    var streamItems = [AnyObject]()
    var favoriteItems = [AnyObject]()
    var userItems = [AnyObject]()
    
    var audioPlayer: AVPlayer?
    var sourceType: CurrentSourceType = .Stream
    var itemsToPlay = [AnyObject]()
    var positionInPlaylist: Int = 0
    
    var nextStreamPartURL: NSURL?
    var nextFavoritesPartURL: NSURL?
    var nextUserPartURL: NSURL?
    
    static let sharedPlayer = SharedAudioPlayer()
    
    func reset() {
        return
    }
    
    func insertStreamItems(items: [SoundCloudItem]) {
        if let lastItem = items.last  {
            self.nextStreamPartURL = lastItem.nextHref
        }
        else {
            self.nextStreamPartURL = nil
        }
        
        for item in items {
            switch item.type {
            case SoundCloudItemTypeTrackRepost:
                fallthrough
            case SoundCloudItemTypeTrack:
                if let trackForItem = item.item as? SoundCloudTrack {
                    if trackForItem.streamable {
//                        self.itemsToPlay.append(trackForItem)
                        self.streamItems.append(trackForItem)
                    }
                }
                break
            case SoundCloudItemTypePlaylistRepost:
                fallthrough
            case SoundCloudItemTypePlaylist:
//                if let playlistFromItem = item.item as? SoundCloudPlaylist {
//                    self.itemsToPlay.append(playlistFromItem)
//                    self.streamItems.append(playlistFromItem)
//                    for playlistTrack in playlistFromItem.tracks {
//                        if playlistTrack.streamable {
//                            self.itemsToPlay.append(playlistTrack)
//                            self.streamItems.append(playlistTrack)
//                        }
//                    }
//                }
                break
            default:
                break
            }
        }
        
    
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer)
        NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidLoadSongs", object: ["type": "favorites", "count": items.count])
    }
    
    func insertFavoriteItems(items: [SoundCloudItem]) {
        if let lastItem = items.last  {
            self.nextFavoritesPartURL = lastItem.nextHref
        }
        else {
            self.nextFavoritesPartURL = nil
        }
        
        for item in items {
            switch item.type {
            case SoundCloudItemTypeTrackRepost:
                fallthrough
            case SoundCloudItemTypeTrack:
                if let trackForItem = item.item as? SoundCloudTrack {
                    if trackForItem.streamable {
                        favoriteItems.append(trackForItem)
                    }
                }
                break
            case SoundCloudItemTypePlaylistRepost:
                fallthrough
            case SoundCloudItemTypePlaylist:
                if let playlistFromItem = item.item as? SoundCloudPlaylist {
                    self.favoriteItems.append(playlistFromItem)
                    for playlistTrack in playlistFromItem.tracks {
                        if playlistTrack.streamable {
                            self.favoriteItems.append(playlistTrack)
                        }
                    }
                }
                break
            default:
                break
            }
        }
        
        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer)
        NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidLoadSongs", object: ["type": "favorites", "count": items.count])
    }
    
    func insertUserItems(items: [SoundCloudItem]) {
        if let lastItem = items.last  {
            self.nextUserPartURL = lastItem.nextHref
        }
        else {
            self.nextUserPartURL = nil
        }
        
        for item in items {
            switch item.type {
            case SoundCloudItemTypeTrackRepost:
                fallthrough
            case SoundCloudItemTypeTrack:
                if let trackForItem = item.item as? SoundCloudTrack {
                    if trackForItem.streamable {
                        userItems.append(trackForItem)
                    }
                }
                break
            case SoundCloudItemTypePlaylistRepost:
                fallthrough
            case SoundCloudItemTypePlaylist:
                //                if let playlistFromItem = item.item as? SoundCloudPlaylist {
                //                    self.favoriteItems.append(playlistFromItem)
                //                    for playlistTrack in playlistFromItem.tracks {
                //                        self.userItems.append(playlistTrack)
                //                    }
                //                }
                break
            default:
                break
            }
        }
        
        if self.sourceType == .User {
            self.switchToUser()
        }
        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer)
        //        self.shuffleEnabled = true
    NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidLoadSongs", object: ["type": "favorites", "count": items.count])
    }
    
    func switchToUser() {
        self.sourceType = .User
    }
    
    func itemDidFinishPlaying(notification: NSNotification) {
        print("item did finish playing")
        self.jumpToItemAtIndex(positionInPlaylist+1)
    }
    
    func getNextSongs() {
        switch self.sourceType {
        case .Stream:
            guard let url = self.nextStreamPartURL else { return }
            SoundCloudAPIClient.sharedClient().getStreamSongsWithURL(url.absoluteString)
            break
        case .Favorites:
            guard let url = self.nextFavoritesPartURL else { return }
            SoundCloudAPIClient.sharedClient().getFavoriteSongsWithURL(url.absoluteString)
            break
        case .User:
            guard let url = self.nextUserPartURL else { return }
            SoundCloudAPIClient.sharedClient().getUserSongsWith(url.absoluteString)
            break
        }
        return
    }
    
    func getNextStreamSongs() {
        guard let url = self.nextStreamPartURL else { return }
        SoundCloudAPIClient.sharedClient().getStreamSongsWithURL(url.absoluteString)
    }
    
    func getNextFavoriteSongs() {
        guard let url = self.nextFavoritesPartURL else { return }
        SoundCloudAPIClient.sharedClient().getFavoriteSongsWithURL(url.absoluteString)
    }
    
    func getNextUserSongs() {
        guard let url = self.nextUserPartURL else { return }
        SoundCloudAPIClient.sharedClient().getUserSongsWith(url.absoluteString)
    }
    
    func togglePlayPause() {
        guard let player = self.audioPlayer else { return }
        
        if player.rate != 0.0 {
            player.pause()
        }
        else {
            if player.status == .ReadyToPlay {
                player.play()
                NSNotificationCenter.defaultCenter().postNotificationName("SharedPlayerDidFinishObject", object: nil)
            }
        }
    }
    
    func nextItem() {
        
    }
    
    func previousItem() {
        
    }
    
    func jumpToItemAtIndex(index: Int) {
        var asset: AVURLAsset
        
        // check overflow count
        switch self.sourceType {
        case .Stream:
            asset = AVURLAsset(URL: streamItems[index].streamingUrl)
        case .Favorites:
            asset = AVURLAsset(URL: favoriteItems[index].streamingUrl)
        case .User:
            asset = AVURLAsset(URL: userItems[index].streamingUrl)
        }
        
        self.audioPlayer = nil
        
        let keys = ["playable"]
        asset.loadValuesAsynchronouslyForKeys(keys) { () -> Void in
            let playerItem = AVPlayerItem(asset: asset)
            
            self.audioPlayer = AVPlayer(playerItem: playerItem)
            self.audioPlayer!.play()
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer?.currentItem)
            NSNotificationCenter.defaultCenter().postNotificationName("SharedPlayerDidFinishObject", object: nil)
        }
        
        positionInPlaylist = index
        
        if positionInPlaylist == self.itemsToPlay.count-1 {
            self.getNextSongs()
        }
        
        return
    }
}