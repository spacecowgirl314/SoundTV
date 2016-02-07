//
//  FavoritesViewController.swift
//  Soundcloud TV
//
//  Created by Chloe Stars on 11/13/15.
//  Copyright © 2015 Chloe Stars. All rights reserved.
//

class FavoritesViewController: ItemViewController {
    override var items: NSMutableArray {
        return self.player.favoriteItemsToShowInTableView
    }
    
    override var playerSourceType: CurrentSourceType? {
        return CurrentSourceTypeFavorites
    }
    
    override func getInitial() {
        SoundCloudAPIClient.sharedClient().getInitialFavoriteSongs()
    }
    
    override func getNext() {
        SharedAudioPlayer.sharedPlayer().getNextFavoriteSongs()
    }
}

