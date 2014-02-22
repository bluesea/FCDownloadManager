//
//  FCViewController.h
//  DownloadManager
//
//  Created by pingyandong on 14-2-22.
//  Copyright (c) 2014年 平 艳东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtensibleTableView.h"
#import "DownloadTask.h"

@interface FCViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ExtensibleTableViewDelegate,DownloadTaskDelegate>
{
    ExtensibleTableView *radioTable;
    NSMutableArray *radioListArray;
    NSMutableArray *downloadingArray;
    NSMutableDictionary *statusDict;
    NSMutableArray *taskArray;
}


@end
