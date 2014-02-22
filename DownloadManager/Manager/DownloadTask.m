//
//  DownloadTask.m
//  Tangyou
//
//  Created by Ping on 14-1-6.
//
//

#import "DownloadTask.h"
//#import "AppUtils.h"
#import "Sql_Utils.h"

#define temporaryFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"]
@implementation DownloadTask
@synthesize downloadDirectory;
@synthesize delegate_down;
@synthesize downCell,name,cellIndex,taskRequest;
@synthesize progress= _progress;
+ (DownloadTask *)sharedDownload
{
    static DownloadTask *sharedDown = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDown = [[self alloc]init];
    });
    return sharedDown;
}

- (id)init
{
    if (self = [super init]) {
        downloadingRequestsQueue = [[ASINetworkQueue alloc] init];
        [downloadingRequestsQueue reset];
        [downloadingRequestsQueue setShowAccurateProgress:YES];
        [downloadingRequestsQueue go];
    }
    return self;
}

- (void)dealloc
{
    [downloadingRequestsQueue release];
    SAFE_RELEASE(_progress);
    [super dealloc];
}


-(void)addDownloadRequest:(ASIHTTPRequest *)request
{
    [request setDelegate:self];
    [request setDownloadProgressDelegate:_progress];
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setNumberOfTimesToRetryOnTimeout:100];
    [request setTimeOutSeconds:20.0];
    NSString *fileName = [[request.url absoluteString] md5EncodedString];
//    NSLog(@"%@",[[request.url absoluteString] md5EncodedString]);
    NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
    [request setTemporaryFileDownloadPath:temporaryDestinationPath];

    if(![request requestHeaders])
    {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:[request temporaryFileDownloadPath] contents:Nil attributes:Nil];
        if(!success)
            NSLog(@"Failed to create file");
    }
    NSLog(@"temp dest path %@",temporaryDestinationPath);
    
    NSString *destPath = [NSString stringWithFormat:@"%@/%@",downloadDirectory,fileName];
    [request setDownloadDestinationPath:destPath];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [downloadingRequestsQueue addOperation:request];
    taskRequest = [request retain];
}


/**
 *  取消所有下载请求
 */
- (void)cancelAllDownloadRequest
{
    [downloadingRequestsQueue cancelAllOperations];
}

#pragma mark - ASIHTTPRequest Delegate -
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"response headers %@",responseHeaders);
    NSLog(@"收到头部！");
    NSLog(@"%f",request.contentLength/1024.0/1024.0);
    NSLog(@"%@",responseHeaders);
    
    float fileLength = request.contentLength/1024.0/1024.0;
    NSString *string = [NSString stringWithFormat:@"%.2fM",fileLength];
    NSLog(@"文件总大小%@",string);
    if (fileLength == 0) {
        NSLog(@"重新请求");
        
    }
    
//    unsigned long long _total = [[responseHeaders objectForKey:@"Content-Length"] longLongValue];
//    float aa = _total/1024/1024;
//    NSLog(@"文件总大小%f",aa);
    //插入下载数据库管理
    
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    [sql createDownloadTable];
    if ([sql canAddDownload:self.name]) {
        [sql addDownloadInfo:self.name url:[request.url absoluteString] duration:@"5‘08" total:request.contentLength status:CSTaskStatus_running];
        _progress.totalSize = fileLength;
    }else{
        NSLog(@"12312");
        [sql updateDownloadInfo:self.name status:CSTaskStatus_running];
    }
    [sql closeDB];

}

//- (void)setProgress:(float)newProgress
//{
//    NSLog(@"进度%.2f",newProgress);
//    [downCell.downBtn setTitle:[NSString stringWithFormat:@"%.2f",newProgress] forState:UIControlStateNormal];
//}

- (void)requestDone:(ASIHTTPRequest *)request
{
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    [sql updateDownloadInfo:self.name status:CSTaskStatus_finished];
    [sql closeDB];
    if ([self.delegate_down respondsToSelector:@selector(removeRequest:index:task:)]) {
        [self.delegate_down removeRequest:request index:self.cellIndex task:self];
    }
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSLog(@"下载失败");
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    [sql updateDownloadInfo:self.name status:CSTaskStatus_failed];
    [sql closeDB];
    if ([self.delegate_down respondsToSelector:@selector(removeRequest:index:task:)]) {
        [self.delegate_down removeRequest:request index:self.cellIndex task:self];
    }
}
@end
