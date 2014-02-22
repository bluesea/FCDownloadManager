//
//  DownloadManager.m
//  Tangyou
//
//  Created by Ping on 14-2-20.
//
//

#import "DownloadManager.h"
#import "ASIHTTPRequest.h"
//#import "AppUtils.h"
#import "Sql_Utils.h"
@implementation DownloadManager
+ (DownloadManager *)sharedDownloadManager
{
    static DownloadManager *sharedDown = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDown = [[self alloc]init];
    });
    return sharedDown;
}

- (id)init
{
    if (self = [super init]) {
        _downloadManagerArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)setAllTaskInterrupted
{
    for (ASIHTTPRequest *request in _downloadManagerArray) {
        NSLog(@"%@",request.url);
        NSString *urlStr = [request.url absoluteString];
        Sql_Utils *sql = [Sql_Utils sharedInstance];
        [sql createDB];
        [sql updateDownload:urlStr status:CSTaskStatus_running];
        [sql closeDB];

    }
}

- (void)dealloc
{
    SAFE_RELEASE(_downloadManagerArray);
    [super dealloc];
}

@end
