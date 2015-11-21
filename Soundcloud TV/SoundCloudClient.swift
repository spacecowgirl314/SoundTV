//
//  SoundCloudClient.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/13/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit

class SoundCloudClient {
    class func imageURLForItem(item: SoundCloudPlaylist, size: String!) -> String {
        if item.artworkUrl != nil {
            let biggerUrl = NSMutableString(string: item.artworkUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            return biggerUrl as String
        }
            // fallback to the avatar if the artwork isn't available (this is what SoundCloud does)
        else if item.user.avatarUrl != nil {
            let biggerUrl = NSMutableString(string: item.user.avatarUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            return biggerUrl as String
        }
        
        return ""
    }
    
    class func imageURLForItem(item: SoundCloudTrack, size: String!) -> String {        
        if item.artworkUrl != nil {
            let biggerUrl = NSMutableString(string: item.artworkUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            return biggerUrl as String
        }
        // fallback to the avatar if the artwork isn't available (this is what SoundCloud does)
        else if item.user.avatarUrl != nil {
            let biggerUrl = NSMutableString(string: item.user.avatarUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            return biggerUrl as String
        }
        
        return ""
    }
    
    class func imageForItem(item: SoundCloudTrack, size: String!, completion:(result: NSData?) -> Void) {
        let session = NSURLSession.sharedSession()

        if item.artworkUrl != nil {
            let biggerUrl = NSMutableString(string: item.artworkUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            if let url = NSURL(string: biggerUrl as String) {
                let task = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    if data != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(result: data)
                        })
                    }
                    else {
                        completion(result: nil)
                    }
                }
                task.resume()
            }
        }
        // fallback to the avatar if the artwork isn't available (this is what SoundCloud does)
        else {
            let biggerUrl = NSMutableString(string: item.user.avatarUrl.absoluteString)
            biggerUrl.replaceOccurrencesOfString("large", withString: size, options: [], range: NSMakeRange(0, biggerUrl.length))
            if let url = NSURL(string: biggerUrl as String) {
                let task = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    if data != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(result: data)
                        })
                    }
                    else {
                        completion(result: nil)
                    }
                }
                task.resume()
            }
        }
        
    }
}