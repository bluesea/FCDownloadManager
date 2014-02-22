//
//  DownloadManager.h
//  Tangyou
//
//  Created by Ping on 14-2-20.
//
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject
@property (nonatomic,retain)NSMutableArray *downloadManagerArray;
+ (DownloadManager *)sharedDownloadManager;
- (void)setAllTaskInterrupted;
@end
