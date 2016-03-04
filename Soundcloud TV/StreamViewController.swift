//
//  SecondViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/12/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

class StreamViewController: ItemViewController {
    override var items: [AnyObject] {
        return self.player.streamItems
    }
    
    override var playerSourceType: CurrentSourceType? {
        return .Stream
    }
    
    override func getInitial() {
        SoundCloudAPIClient.sharedClient().getInitialStreamSongs()
    }
    
    override func getNext() {
        SharedAudioPlayer.sharedPlayer.getNextStreamSongs()
    }
}

