//
//  AppDelegate.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

import UIKit
import MediaPlayer
import SoundCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SCSoundCloud.setClientID(Keys.clientID(), secret: Keys.clientSecret(), redirectURL: NSURL(string: "https://soundcloud.com"))
        
        MPRemoteCommandCenter.sharedCommandCenter().pauseCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            guard let audioPlayer = SharedAudioPlayer.sharedPlayer().audioPlayer else {
                return .NoSuchContent
            }
            audioPlayer.pause()
            return .Success
        }
        MPRemoteCommandCenter.sharedCommandCenter().playCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            guard let audioPlayer = SharedAudioPlayer.sharedPlayer().audioPlayer else {
                return .NoSuchContent
            }
            audioPlayer.play()
            return .Success
        }
        MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.addTargetWithHandler { (event) ->
            MPRemoteCommandHandlerStatus in
            SharedAudioPlayer.sharedPlayer().nextItem()
            return .Success
        }
        MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.addTargetWithHandler { (event) ->
            MPRemoteCommandHandlerStatus in
            SharedAudioPlayer.sharedPlayer().previousItem()
            return .Success
        }
        
        // -----
        self.window?.makeKeyAndVisible()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didFailToAuthenticate"), name: "SoundCloudAPIClientDidFailToAuthenticate", object: nil)
        didFailToAuthenticate()
        
        return true
    }
    
    func didFailToAuthenticate() {
        let rootViewController = self.window!.rootViewController!
        let storyboard = rootViewController.storyboard!
        if !SoundCloudAPIClient.sharedClient().isLoggedIn() {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("Authentication")
            rootViewController.presentViewController(viewController, animated: false, completion: nil)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        if SharedAudioPlayer.sharedPlayer().streamItemsToShowInTableView.count > 0 {
//            SoundCloudAPIClient.sharedClient().getFutureStreamSongs()
//            SoundCloudAPIClient.sharedClient().getFutureFavoriteSongs()
//        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

