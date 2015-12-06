//
//  SharedAudioPlayer.swift
//  SoundCloud TV
//
//  Created by Chloe Stars on 11/20/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

/*
let rangeOfOverlap : NSRange?

searching: for track in streamItemsToShowInTableView.reverseObjectEnumerator() {
for (index,otherTrack) in newStream.enumerate() {
if track.identifier == otherTrack.identifier {
// build range here, ALSO, could be potential location of a one-off
rangeOfOverlap = NSRange(location: index, length: newStream.count-index)
break searching
}
}
}
*/

extension SharedAudioPlayer {
    func processFavorites(newStream : NSArray) {
        var isOverlapping = false
        let removalArray = NSMutableArray()
        var isAfterCurrentItem = false
        
        for track in favoriteItemsToShowInTableView.reverseObjectEnumerator() {
            if isOverlapping {
                var hasBeenFound = false
                // check if the item is in the other stream
                comparing: for otherTrack in newStream.reverseObjectEnumerator() {
                    if let otherTrack = otherTrack as? SoundCloudItem {
                        if track.identifier == otherTrack.item.identifier {
                            // TODO: update properties on the track
                            hasBeenFound = true
                            break comparing
                        }
                        if sourceType == CurrentSourceTypeFavorites {
                            if track.identifier == currentItem().identifier {
                                isAfterCurrentItem = true
                            }
                        }
                    }
                }
                
                if !hasBeenFound {
                    // we're before the playing item, adjust the playlist
                    // TODO: this doesn't work?! both with and without this the player stops and if we press play it skips ahead 2 times
                    if isAfterCurrentItem {
                        positionInPlaylist--
                    }
                    removalArray.addObject(track)
                }
            }
            else {
                searching: for otherTrack in newStream.reverseObjectEnumerator() {
                    if let otherTrack = otherTrack as? SoundCloudItem {
                        if track.identifier == otherTrack.item.identifier {
                            // build range here, ALSO, could be potential location of a one-off
                            isOverlapping = true
                            break searching
                        }
                    }
                }
            }
        }
        
        // if we aren't overlapping it's cause we probably came back to the app at a really later time
        if (isOverlapping) {
            for track in removalArray {
                // hopefully this works even though it might be a copy?
                favoriteItemsToShowInTableView.removeObject(track)
                // find in queue items by matching against url
                if sourceType == CurrentSourceTypeFavorites {
                    searching: for item in audioPlayer!.items() {
                        if let asset = item.asset as? AVURLAsset {
                            if let _ = track as? SoundCloudTrack {
                                if asset.URL == track.streamingUrl {
                                    audioPlayer!.removeItem(item)
                                    // adjust player position item number
                                    break searching
                                }
                            }
                        }
                    }
                    // the below two for loops might be able to be simplified into itemsToPlay.removeObject(track)
                    if itemsToPlay != nil {
//                        let test = itemsToPlay
                        searching: for item in itemsToPlay {
                            if let asset = item.asset as? AVURLAsset {
                                if let _ = track as? SoundCloudTrack {
                                    if asset.URL == track.streamingUrl {
                                        itemsToPlay.removeObject(item)
                                        // adjust player position item number
                                        break searching
                                    }
                                }
                            }
                        }
                    }
                    if shuffledItemsToPlay != nil {
                        searching: for item in shuffledItemsToPlay {
                            if let asset = item.asset as? AVURLAsset {
                                if let _ = track as? SoundCloudTrack {
                                    if asset.URL == track.streamingUrl {
                                        shuffledItemsToPlay.removeObject(item)
                                        // adjust player position item number
                                        break searching
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if removalArray.count > 0 {
                NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidLoadSongs", object: nil)
            }
        }
    }

    
    /*
        Algorithm Overview:
            First we start from the back of the current stream,
        then we find our first match at the back in reverse order.
        After we've found our first match we continue moving forward
        and check if it's in the other. If it is we set a flag and
        only it's added to a removal queue. We're also keeping an eye out
        for the currentItem so that we can make adjustments to the
        position in the playlist. After we're done going through all
        the tracks we iterate through the removal queue and remove the
        items from current stream and then search for the item in the
        player queue and remove it by matching by the streamingUrl with
        the asset URL.
    */
    func processStream(newStream : NSArray) {
        var isOverlapping = false
        let removalArray = NSMutableArray()
        var isAfterCurrentItem = false
        
        for track in streamItemsToShowInTableView.reverseObjectEnumerator() {
            if isOverlapping {
                var hasBeenFound = false
                // check if the item is in the other stream
                comparing: for otherTrack in newStream.reverseObjectEnumerator() {
                    if let otherTrack = otherTrack as? SoundCloudItem {
                        if track.identifier == otherTrack.item.identifier {
                            // TODO: update properties on the track
                            hasBeenFound = true
                            break comparing
                        }
                        if sourceType == CurrentSourceTypeStream {
                            if track.identifier == currentItem().identifier {
                                isAfterCurrentItem = true
                            }
                        }
                    }
                }
                
                if !hasBeenFound {
                    // we're before the playing item, adjust the playlist
                    if isAfterCurrentItem {
                        positionInPlaylist--
                    }
                    removalArray.addObject(track)
                }
            }
            else {
                searching: for otherTrack in newStream.reverseObjectEnumerator() {
                    if let otherTrack = otherTrack as? SoundCloudItem {
                        if track.identifier == otherTrack.item.identifier {
                            // build range here, ALSO, could be potential location of a one-off
                            isOverlapping = true
                            break searching
                        }
                    }
                }
            }
        }
        
        // if we aren't overlapping it's cause we probably came back to the app at a really later time
        if (isOverlapping) {
            for track in removalArray {
                // hopefully this works even though it might be a copy?
                streamItemsToShowInTableView.removeObject(track)
                // find in queue items by matching against url
                if sourceType == CurrentSourceTypeStream {
                    searching: for item in audioPlayer!.items() {
                        if let asset = item.asset as? AVURLAsset {
                            if let _ = track as? SoundCloudTrack {
                                if asset.URL == track.streamingUrl {
                                    audioPlayer!.removeItem(item)
                                    // adjust player position item number
                                    break searching
                                }
                            }
                        }
                    }
                    // the below two for loops might be able to be simplified into itemsToPlay.removeObject(track)
                    if itemsToPlay != nil {
                        searching: for item in itemsToPlay {
                            if let asset = item.asset as? AVURLAsset {
                                if let _ = track as? SoundCloudTrack {
                                    if asset.URL == track.streamingUrl {
                                        itemsToPlay.removeObject(item)
                                        // adjust player position item number
                                        break searching
                                    }
                                }
                            }
                        }
                    }
                    if shuffledItemsToPlay != nil {
                        searching: for item in shuffledItemsToPlay {
                            if let asset = item.asset as? AVURLAsset {
                                if let _ = track as? SoundCloudTrack {
                                    if asset.URL == track.streamingUrl {
                                        shuffledItemsToPlay.removeObject(item)
                                        // adjust player position item number
                                        break searching
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if removalArray.count > 0 {
                NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidLoadSongs", object: nil)
            }
        }
    }
    
    func processStreamForNewSongs(newTracks : NSArray) {
        processStream(newTracks)
        
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
        processFavorites(newTracks)
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
                // we may need to continue compare ids and look for the first match
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
            let newItems = newTracks.objectsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: newPostIndex)))
            print("\(newItems.count) new favorites")
            self.insertFavoriteItemsAtBeginning(newItems)
            if self.sourceType == CurrentSourceTypeFavorites {
                self.positionInPlaylist += newPostIndex
            }
        }
        
        //        tableView.insertRowsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, newPostIndex)), withAnimation: .SlideDown)
    }
}