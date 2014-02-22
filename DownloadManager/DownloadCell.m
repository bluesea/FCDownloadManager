//
//  DownloadCell.m
//  Tangyou
//
//  Created by Ping on 14-2-19.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "DownloadCell.h"

@interface DownloadCell ()


@end

@implementation DownloadCell
@synthesize _progress;
#pragma mark - Memory Management
- (void)dealloc
{
    //TODO: release objects here
    SAFE_RELEASE(_progress);
    SAFE_RELEASE(_nameLabel);
    [super dealloc];
}

#pragma mark - Cell LifeCycle
// 自动使用xib创建，返回autorelease的Cell对象
+ (DownloadCell*)cell
{
    DownloadCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCell" owner:nil options:nil] objectAtIndex:0];
    return cell;
}

#pragma mark - Cell Actions
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
