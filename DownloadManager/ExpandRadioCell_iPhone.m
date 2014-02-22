//
//  ExpandRadioCell_iPhone.m
//  Tangyou
//
//  Created by Ping on 14-1-6.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import "ExpandRadioCell_iPhone.h"
#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"]
#define temporaryFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"]

@interface ExpandRadioCell_iPhone ()


@end

@implementation ExpandRadioCell_iPhone
#pragma mark - Memory Management
- (void)dealloc
{
    [_radioNameL release];
    [super dealloc];
}

#pragma mark - Cell LifeCycle
// 自动使用xib创建，返回autorelease的Cell对象
+ (ExpandRadioCell_iPhone*)cell
{
    ExpandRadioCell_iPhone *cell = [[[NSBundle mainBundle] loadNibNamed:@"ExpandRadioCell_iPhone" owner:nil options:nil] objectAtIndex:0];
    return cell;
}


#pragma mark - Cell Logic
// 重置UI元素，防止重用时出现显示错乱的问题
- (void)resetUI
{
    
    // TODO: 重置一些不会立刻更新或者不是每个cell都有内容显示的控件的值
    
}

@end
