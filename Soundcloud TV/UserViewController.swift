//
//  UserViewController.swift
//  Sound TV
//
//  Created by Chloe Stars on 2/27/16.
//  Copyright © 2016 Chloe Stars. All rights reserved.
//

import UIKit

class UserViewController: ItemViewController {
    override var items: [AnyObject] {
        return self.player.userItems
    }
    
    override var playerSourceType: CurrentSourceType? {
        return .User
    }
    
    override func getInitial() {
        return
        //SoundCloudAPIClient.sharedClient.getInitialFavoriteSongs()
    }
    
    override func getNext() {
        SharedAudioPlayer.sharedPlayer.getNextUserSongs()
    }
}

class TitledUICollectionView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
}