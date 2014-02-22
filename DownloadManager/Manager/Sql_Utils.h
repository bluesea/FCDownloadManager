//
//  Sql_Utils.h
//  Tangyou
//
//  Created by Ping on 13-12-31.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"




@interface Sql_Utils : NSObject
{
    FMDatabase *_db;
    FMDatabaseQueue *_queue;
}

+ (Sql_Utils *)sharedInstance;

#pragma mark -数据库创建和关闭
- (void)createDB;
- (void)closeDB;

#pragma mark -下载数据库管理
- (void)createDownloadTable;
- (void)addDownloadInfo:(NSString *)name url:(NSString *)downloadUrl duration:(NSString *)durationString total:(float)totalSize status:(CSTaskStatus)status;
- (void)deleteDownloadInfo:(NSString *)name;
- (void)updateDownloadInfo:(NSString *)name status:(CSTaskStatus)status;
- (void)updateDownload:(NSString *)url status:(CSTaskStatus)status;
- (NSArray *)getDownloadIndfo;
- (BOOL)canAddDownload:(NSString *)name;
- (BOOL)isDownloading:(NSString *)urlString;
@end
