//
//  SoundCloudAPIClient.h
//  SoundcloudPlayer
//
//  Created by Philip Brechler on 25.06.14.
//  Copyright (c) 2014 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundCloudAPIClient : NSObject

+ (SoundCloudAPIClient *)sharedClient;
- (void)logout;
- (BOOL)isLoggedIn;
- (void)getInitialStreamSongs;
- (void)getStreamSongsWithURL:(NSString *)url;
- (void)getInitialFavoriteSongs;
- (void)getFavoriteSongsWithURL:(NSString *)url;
- (void)saveFavoriteWithSongID:(NSString*)songID completion:(void (^)(NSError *error))completion;
- (void)removeFavoriteWithSongID:(NSString*)songID completion:(void (^)(NSError *error))completion;
- (void)reloadStream;
//- (void)getFutureSongs;
@end
