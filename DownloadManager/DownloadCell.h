//
//  DownloadCell.h
//  Tangyou
//
//  Created by Ping on 14-2-19.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProgressIndicator;
@interface DownloadCell : UITableViewCell
{
    
}
@property (nonatomic,retain)IBOutlet UIButton *downBtn;
@property (nonatomic,retain)IBOutlet UILabel *nameLabel;
@property (nonatomic,retain)IBOutlet ProgressIndicator *_progress;
@property(nonatomic,assign)CSTaskStatus status;

+ (DownloadCell*)cell;

@end
