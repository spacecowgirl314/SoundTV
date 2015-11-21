//
//  SharedAudioPlayer.swift
//  SoundCloud TV
//
//  Created by Chloe Stars on 11/20/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

extension SharedAudioPlayer {
    func processStreamForNewSongs(newTracks : NSArray) {
        var tracksInRange = false
        var newPostIndex = 0
        var mostRecentPostId : Int = 0
        
        if self.streamItemsToShowInTableView.count > 0 {
            if let track = self.streamItemsToShowInTableView[0] as? SoundCloudTrack {
                mostRecentPostId = track.identifier as Int
            }
        }
        for (index,object) in newTracks.enumerate() {
            // go until we reach the most recent track ID and then break
            if let item = object as? SoundCloudItem {
                if item.item.identifier == mostRecentPostId {
                    tracksInRange = true
                    newPostIndex = index
                    break
                }
            }
            
        }
        
        if !tracksInRange {
            // there was a gap in the new posts between now and what we have
            // we can do something like tweetbot and have a gap button
            newPostIndex = newTracks.count-1
        }
        
        // we're adding to what we have
        if self.streamItemsToShowInTableView.count > 0 && newPostIndex > 0 {
            print("new posts")
            let newItems = newTracks.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: newPostIndex)))
            self.insertStreamItemsAtBeginning(newItems)
            if self.sourceType == CurrentSourceTypeStream {
                self.positionInPlaylist += newPostIndex
            }
        }
        
//        tableView.insertRowsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, newPostIndex)), withAnimation: .SlideDown)
    }
    
    func processFavoritesForNewSongs(newTracks : NSArray) {
        var tracksInRange = false
        var newPostIndex = 0
        var mostRecentPostId : Int = 0
        
        if self.favoriteItemsToShowInTableView.count > 0 {
            if let track = self.favoriteItemsToShowInTableView[0] as? SoundCloudTrack {
                mostRecentPostId = track.identifier as Int
            }
        }
        for (index,object) in newTracks.enumerate() {
            // go until we reach the most recent track ID and then break
            if let item = object as? SoundCloudItem {
                if item.item.identifier  == mostRecentPostId {
                    tracksInRange = true
                    newPostIndex = index
                    break
                }
            }
            
        }
        
        if !tracksInRange {
            // there was a gap in the new posts between now and what we have
            // we can do something like tweetbot and have a gap button
            newPostIndex = newTracks.count-1
        }
        
        // we're adding to what we have
        if self.favoriteItemsToShowInTableView.count > 0 && newPostIndex > 0 {
            print("new posts")
            let newItems = newTracks.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: newPostIndex)))
            self.insertFavoriteItemsAtBeginning(newItems)
            if self.sourceType == CurrentSourceTypeFavorites {
                self.positionInPlaylist += newPostIndex
            }
        }
        
        //        tableView.insertRowsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, newPostIndex)), withAnimation: .SlideDown)
    }
}