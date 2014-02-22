//
//  DownloadTask.h
//  Tangyou
//
//  Created by Ping on 14-1-6.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ExpandRadioCell_iPhone.h"
#import "DownloadCell.h"
#import "ProgressIndicator.h"

@protocol DownloadTaskDelegate <NSObject>
@optional
- (void)removeRequest:(ASIHTTPRequest *)request index:(int)_index task:(id)_task;
- (void)changeProgress:(float)progress withRequest:(ASIHTTPRequest *)request;
@end


@interface DownloadTask : NSObject<ASIProgressDelegate,ASIHTTPRequestDelegate>
{
    NSString *downloadDirectory;
    ASINetworkQueue *downloadingRequestsQueue;
    __block uint fileSize; //以B为单位,文件大小
    __block uint completedSize; //已下载文件的大小
    ProgressIndicator *progress;
}
@property (nonatomic, retain)NSString *downloadDirectory;
@property (nonatomic, assign)id<DownloadTaskDelegate>delegate_down;
@property (nonatomic,retain)DownloadCell *downCell;
@property (nonatomic,assign)NSString *name;
@property (nonatomic,assign)int cellIndex;
@property (nonatomic,retain)ASIHTTPRequest *taskRequest;
@property (nonatomic,retain)ProgressIndicator *progress;
+ (DownloadTask *)sharedDownload;
-(void)addDownloadRequest:(ASIHTTPRequest *)request;
- (void)cancelAllDownloadRequest;
@end
