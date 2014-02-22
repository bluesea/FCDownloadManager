//
//  DownloadViewController.h
//  Tangyou
//
//  Created by Ping on 14-2-19.
//
//

#import <UIKit/UIKit.h>
#import "DownloadTask.h"

@interface DownloadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DownloadTaskDelegate>
{
    UITableView *downloadTable;
}

@end
