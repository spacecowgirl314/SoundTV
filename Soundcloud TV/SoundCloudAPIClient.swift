//
//  SoundCloudAPIClient.swift
//  SoundCloud TV
//
//  Created by Chloe Stars on 11/20/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import SoundCloud

extension SoundCloudAPIClient {
    func getUserSongs(identifier: String) {
        let account = SCSoundCloud.account()
        
        SCRequest.performMethod(SCRequestMethodGET, onResource: NSURL(string: "https://api.soundcloud.com/users/\(identifier)/tracks?linked_partitioning=1"), usingParameters: nil, withAccount: account, sendingProgressHandler: nil) { (response: NSURLResponse!, data: NSData?, error: NSError?) -> Void in
            if (error != nil) {
                print("Ooops, something went wrong: \(error!.localizedDescription)")
                NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientIsUnreachable", object: nil)
            }
            else {
                print("Got data, yeah")
                guard let data = data else { return }
                do {
                    if let objectFromData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                        let itemsToInsert = SoundCloudItem.soundCloudItemsFromResponse(objectFromData)
                        SharedAudioPlayer.sharedPlayer.insertUserItems(itemsToInsert)
                    }
                }
                catch {
                    NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidFailToLoadSongs", object: nil)
                }
            }
        }
    }
    
    func getUserSongsWith(url: String) {
        let account = SCSoundCloud.account()
        
        SCRequest.performMethod(SCRequestMethodGET, onResource: NSURL(string: url), usingParameters:nil, withAccount: account, sendingProgressHandler: nil) { (response:NSURLResponse?, data:NSData?, error: NSError?) -> Void in
            if let responseError = error {
                print("Oops, something went wrong \(responseError.localizedDescription)")
            } else {
                guard let data = data else { return }
                do {
                    if let objectFromData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                        let itemsToInsert = SoundCloudItem.soundCloudItemsFromResponse(objectFromData)
                        SharedAudioPlayer.sharedPlayer.insertUserItems(itemsToInsert)
                    }
                }
                catch {
                    NSNotificationCenter.defaultCenter().postNotificationName("SoundCloudAPIClientDidFailToLoadSongs", object: nil)
                }
            }
        }
    }
    
//    func getFutureStreamSongs() {
//        let account = SCSoundCloud.account()
//        
//        SCRequest.performMethod(SCRequestMethodGET, onResource: NSURL(string: "https://api.soundcloud.com/me/activities?limit=50"), usingParameters: nil, withAccount: account, sendingProgressHandler: nil) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
//            if error != nil {
//                print("Oops, something went wrong \(error!.localizedDescription)")
//            }
//            else {
//                print("Got data, yeah")
//                do {
//                    let objectFromData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
//                    let itemsFromResponse = SoundCloudItem.soundCloudItemsFromResponse(objectFromData)
//                    SharedAudioPlayer.sharedPlayer.processStreamForNewSongs(itemsFromResponse)
//                }
//                catch {
//                    
//                }
//            }
//        }
//    }
//    
//    func getFutureFavoriteSongs() {
//        let account = SCSoundCloud.account()
//        
//        if let scUserID = NSUserDefaults.standardUserDefaults().objectForKey("scUserId") {
//            SCRequest.performMethod(SCRequestMethodGET, onResource: NSURL(string: "https://api.soundcloud.com/users/\(scUserID)/favorites?limit=100&offset=0&linked_partitioning=1"), usingParameters: nil, withAccount: account, sendingProgressHandler: nil) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
//                if error != nil {
//                    print("Oops, something went wrong \(error!.localizedDescription)")
//                }
//                else {
//                    print("Got data, yeah")
//                    do {
//                        let objectFromData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
//                        let itemsFromResponse = SoundCloudItem.soundCloudItemsFromResponse(objectFromData)
//                        SharedAudioPlayer.sharedPlayer().processFavoritesForNewSongs(itemsFromResponse)
//                    }
//                    catch {
//                        
//                    }
//                }
//            }
//        }
//    }
}
