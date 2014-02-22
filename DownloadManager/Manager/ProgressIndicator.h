//
//  ProgressIndicator.h
//  Tangyou
//
//  Created by Ping on 14-1-6.
//
//

#import <UIKit/UIKit.h>
#import "CircleProgressView.h"

@interface ProgressIndicator : UIView<CircularProgressDelegate>

//下载资源的总大小
@property CGFloat totalSize;
-(void)setProgress:(float)progress animated:(BOOL)animated;
@end
