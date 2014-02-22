//
//  DownloadViewController.m
//  Tangyou
//
//  Created by Ping on 14-2-19.
//
//

#import "DownloadViewController.h"
#import "DownloadCell.h"
#import "Sql_Utils.h"
//#import "AppUtils.h"
#import "DownloadManager.h"
//#import <AVFoundation/AVFoundation.h>
#import "NSString+FCStringFormat.h"


@interface DownloadViewController ()
{
    NSMutableArray *downloadTaskArray;
    NSMutableArray *testDownloadUrlArray;
}
@end

@implementation DownloadViewController

- (void)dealloc{
    SAFE_RELEASE(downloadTaskArray);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [DownloadTask sharedDownload].delegate_down = nil;
//    [[DownloadTask sharedDownload] cancelAllDownloadRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"下载";
    downloadTaskArray = [[NSMutableArray alloc]init];
    testDownloadUrlArray = [[NSMutableArray alloc]init];
//    NSURL *url = [NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/114919473/114909440115200128.mp3?xcode=f217172a5089a0ddc8807ce1a6822092f48ae2a732e86bfd"];
//    [testDownloadUrlArray addObject:url];
//    [testDownloadUrlArray addObject:[NSURL URLWithString:@"http://zhangmenshiting.baidu.com/data2/music/114946264/114944077133200128.mp3?xcode=5c967ee3728e5cd92bb54d662ab462b3a201dc3ec9586f57"]];
    
    //读取数据库
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    NSArray *array = [sql getDownloadIndfo];
    NSLog(@"%@",array);
    [testDownloadUrlArray addObjectsFromArray:array];
    [sql closeDB];
    
    downloadTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-(IsIOS7?0:20)) style:UITableViewStylePlain];
    downloadTable.dataSource = self;
    downloadTable.delegate = self;
    downloadTable.rowHeight = 105;
    [self.view addSubview:downloadTable];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [testDownloadUrlArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier=@"CCopenCell";
    DownloadCell *cell = (DownloadCell *)[tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    if (cell == nil) {
        cell = [DownloadCell cell];
    }
    NSDictionary *dict = [testDownloadUrlArray objectAtIndex:indexPath.row];
    NSString *name = [dict objectForKey:@"name"];
    cell.nameLabel.text = name;
    
    NSString *urlStr = [dict objectForKey:@"url"];
    float size = [[dict objectForKey:@"totalsize"]floatValue];
    cell._progress.totalSize = size/1024.0/1024.0;
    NSString *fileName = [urlStr md5EncodedString];
    NSString *destPath = [NSString stringWithFormat:@"%@/%@",fileDestination,fileName];
    
    //下载完成
    if ([[NSFileManager defaultManager]fileExistsAtPath:destPath]) {
        NSLog(@"已存在");
        [cell._progress setProgress:1.0 animated:YES];
    }else{
        NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:temporaryDestinationPath error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        unsigned long long fileSize = [fileSizeNumber unsignedLongLongValue];
        float progress = fileSize/size;
        [cell._progress setProgress:progress animated:YES];
    }
   
//    int status = [[dict valueForKey:@"status"] intValue];
//    if (status == 1) {
//        NSLog(@"下载ing");
//        cell.status = CSTaskStatus_running;
//    }
    
    if ([self isDownloading:urlStr]) {
        //正在下载
        NSArray *array = [DownloadManager sharedDownloadManager].downloadManagerArray;
        for (ASIHTTPRequest *request in array) {
            if ([request.url isEqual:[NSURL URLWithString:urlStr]]) {
                NSLog(@"这个正在下载中");
                cell.status = CSTaskStatus_running;
                request.downloadProgressDelegate = cell._progress;
            }
        }
    }else{
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //清空文件+数据库中对应数据
        NSDictionary *dict = [testDownloadUrlArray objectAtIndex:indexPath.row];
        NSString *urlStr = [dict objectForKey:@"url"];
        NSString *fileName = [urlStr md5EncodedString];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@",fileDestination,fileName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:destPath]) {
            [[NSFileManager defaultManager]removeItemAtPath:destPath error:nil];
        }else{
            NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
            [[NSFileManager defaultManager]removeItemAtPath:temporaryDestinationPath error:nil];
        }
        
        Sql_Utils *sql = [Sql_Utils sharedInstance];
        [sql createDB];
        [sql deleteDownloadInfo:[dict objectForKey:@"name"]];
        [sql closeDB];

        
        [testDownloadUrlArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
        }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击下载
    [self addDownloadTask:indexPath.row];
}


- (BOOL)isDownloading:(NSString *)urlString
{
    BOOL flag = NO;
    Sql_Utils *sql = [Sql_Utils sharedInstance];
    [sql createDB];
    flag = [sql isDownloading:urlString];
    [sql closeDB];
    return flag;
}

/**
 *  点击下载，添加到下载队列
 *
 *  @param _url 下载地址
 */
- (void)addDownloadTask:(int)index
{
    NSIndexPath *indexPath= [NSIndexPath indexPathForRow:index inSection:0];
    DownloadCell *cell = (DownloadCell *)[downloadTable cellForRowAtIndexPath:indexPath];
    DownloadTask *task = [DownloadTask sharedDownload];
    task.delegate_down = self;
    task.progress = cell._progress;
//    task.taskRequest.downloadProgressDelegate = cell._progress;

    NSDictionary *dict = [testDownloadUrlArray objectAtIndex:index];
    NSString *urlString = [dict objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *name = [dict objectForKey:@"name"];
    task.name = name;
    task.cellIndex = index;
    
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url]autorelease];
    NSString *fileName = [[request.url absoluteString] md5EncodedString];
    NSString *destPath = [NSString stringWithFormat:@"%@/%@",fileDestination,fileName];
    
    //下载完成
    if ([[NSFileManager defaultManager]fileExistsAtPath:destPath]) {
        NSLog(@"已存在,播放该MP3");
        [cell._progress setProgress:1.0 animated:YES];
        //播放该MP3
        [self playMP3:[NSURL fileURLWithPath:destPath]];
        return;
    }
    //正在下载
    if (cell.status == CSTaskStatus_running) {
        [self pauseRequestAtIndex:index];
        return;
    }else{
        //暂停继续下载/开始下载
        Sql_Utils *sql = [Sql_Utils sharedInstance];
        [sql createDB];
        [sql createDownloadTable];
        if ([sql canAddDownload:name]) {
            //首次下载
            [task setDownloadDirectory:fileDestination];
            [task addDownloadRequest:request];
        }else{
            //继续断点下载
            NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
            
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:temporaryDestinationPath error:nil];
            
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            unsigned long long fileSize = [fileSizeNumber unsignedLongLongValue];
            int size = (int)fileSize;
            NSString *downloadLen = [NSString stringWithFormat:@"bytes=%d-",size];
            NSLog(@"downloadLen %@",downloadLen);
            [request addRequestHeader:@"Range" value:downloadLen];
            [task setDownloadDirectory:fileDestination];
            [task addDownloadRequest:request];
            float filesize = [[dict objectForKey:@"totalsize"]floatValue];
            cell._progress.totalSize = filesize/1024.0/1024.0;
        }
        cell.status = CSTaskStatus_running;
        [sql closeDB];
        DownloadManager *manager = [DownloadManager sharedDownloadManager];
        [manager.downloadManagerArray addObject:task.taskRequest];
    }
}

/**
 *  暂停任务
 *
 *  @param index 对应任务位置
 */
- (void)pauseRequestAtIndex:(int)index
{
    NSIndexPath *indexPath= [NSIndexPath indexPathForRow:index inSection:0];
    DownloadCell *cell = (DownloadCell *)[downloadTable cellForRowAtIndexPath:indexPath];
    cell.status = CSTaskStatus_interrupted;
    DownloadTask *task = [DownloadTask sharedDownload];
    task.delegate_down = self;
    task.progress = cell._progress;
    NSDictionary *dict = [testDownloadUrlArray objectAtIndex:index];
    NSString *urlString = [dict objectForKey:@"url"];
//    NSURL *url = [NSURL URLWithString:urlString];
    NSString *name = [dict objectForKey:@"name"];
    task.name = name;
    task.cellIndex = index;
    
    NSArray *array = [DownloadManager sharedDownloadManager].downloadManagerArray;
    for (ASIHTTPRequest *request in array) {
        if ([request.url isEqual:[NSURL URLWithString:urlString]]) {
            NSLog(@"这个正在下载中");
            cell.status = CSTaskStatus_interrupted;
            request.downloadProgressDelegate = cell._progress;
            [request clearDelegatesAndCancel];
            
            Sql_Utils *sql = [Sql_Utils sharedInstance];
            [sql createDB];
            [sql updateDownloadInfo:name status:CSTaskStatus_interrupted];
            [sql closeDB];
        }
    }
}

/**
 *  继续下载
 *
 *  @param index 对应任务位置
 */
-(void)resumeRequestAtIndex:(id)sender
{
   
}

/**
 *  取消某个下载
 *
 *  @param index 对应位置
 */
- (void)cancelRequestAtIndex:(int)index
{
//    ASIHTTPRequest *request = [downloadingArray objectAtIndex:index];
//    [request clearDelegatesAndCancel];
    
    //移除数据库中相关内容
    
}

#pragma mark -DownloadTaskDelegate
//完成下载 index对应cell所在行 taskarray存储任务
- (void)removeRequest:(ASIHTTPRequest *)request index:(int)_index task:(id)_task
{
    DownloadManager *manager = [DownloadManager sharedDownloadManager];
    [manager.downloadManagerArray removeObject:request];
}


#pragma mark -PlayMusic
- (void)playMP3:(NSURL *)url
{
    

}

@end