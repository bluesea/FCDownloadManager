//
//  Sql_Utils.m
//  Tangyou
//
//  Created by Ping on 13-12-31.
//
//

#import "Sql_Utils.h"

@implementation Sql_Utils

+ (Sql_Utils *)sharedInstance
{
    static Sql_Utils *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Sql_Utils alloc]init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -数据库创建和关闭
- (void)createDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"tangyou.db"];
    
    NSLog(@"数据库存储位置：%@",dbPath);
    
    _db = [FMDatabase databaseWithPath:dbPath] ;
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    if (![_db open])
    {
        NSLog(@"Could not open db.");
    }
}

- (void)closeDB
{
    if ([_db open]) {
        
    }
    [_db close];
    [_queue close];
}

#pragma mark -下载数据库管理
- (void)createDownloadTable
{
    if(![_db tableExists:@"download"])
    {
        [_queue inDatabase:^(FMDatabase *db){
            [db executeUpdate:@"CREATE TABLE download (name text,url text,duration text,totalsize float,status float)"];
        }];
    }
}

/**
 *  添加下载信息
 *
 *  @param name           下载名
 *  @param downloadUrl    下载地址
 *  @param durationString 下载内容时长
 *  @param totalSize      下载内容总大小
 */
- (void)addDownloadInfo:(NSString *)name url:(NSString *)downloadUrl duration:(NSString *)durationString total:(float)totalSize status:(CSTaskStatus)status
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO download (name,url,duration,totalsize,status) VALUES (?,?,?,?,?)",name,downloadUrl,durationString,[NSNumber numberWithFloat:totalSize],[NSNumber numberWithInt:status]];
    }];
}

- (void)deleteDownloadInfo:(NSString *)name
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"delete from download where name = ?",name];
    }];
}

/**
 *  根据下载文件名更新下载状态
 *
 *  @param name      下载文件名
 *  @param status    下载状态
 */
- (void)updateDownloadInfo:(NSString *)name status:(CSTaskStatus)status
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE download set status = ? where name = ?",[NSNumber numberWithInt:status],name];
    }];
}

- (void)updateDownload:(NSString *)url status:(CSTaskStatus)status
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE download set status = ? where url = ?",[NSNumber numberWithInt:status],url];
    }];
}

- (NSArray *)getDownloadIndfo
{
    NSMutableArray *resultArray = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM download order by rowid desc"];
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"name"];
            NSString *url = [rs stringForColumn:@"url"];
            NSString *duration = [rs stringForColumn:@"duration"];
            float size = [rs longForColumn:@"totalsize"];
            int status = [rs intForColumn:@"status"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:name forKey:@"name"];
            [dict setObject:url forKey:@"url"];
            [dict setObject:duration forKey:@"duration"];
            [dict setObject:[NSNumber numberWithFloat:size] forKey:@"totalsize"];
            [dict setObject:[NSNumber numberWithInt:status] forKey:@"status"];
            [resultArray addObject:dict];
        }
        [rs close];
    }];

    return resultArray;
}

- (BOOL)canAddDownload:(NSString *)name
{
    __block BOOL flag = YES;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM download where name = ? ",name];
        while ([rs next]) {
            flag=NO;
            break;
        }
        [rs close];
    }];
    return flag;
}

- (BOOL)isDownloading:(NSString *)urlString
{
    __block BOOL flag = YES;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM download where url= ? ",urlString];
        while ([rs next]) {
            int status = [rs intForColumn:@"status"];
            if (status == CSTaskStatus_running) {
                flag = YES;
            }else{
                flag=NO;
            }
            break;
        }
        [rs close];
    }];
    return flag;
}

@end
