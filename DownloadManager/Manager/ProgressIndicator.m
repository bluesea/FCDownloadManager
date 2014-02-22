//
//  ProgressIndicator.m
//  Tangyou
//
//  Created by Ping on 14-1-6.
//
//

#import "ProgressIndicator.h"

@implementation ProgressIndicator{
    CircleProgressView *_progressView;
    UILabel *_label;
}
@synthesize totalSize = _totalSize;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initView];

}

-(id)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView{
    [self initProgressView];
    [self initLabel];
}

-(void)initProgressView{
//    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    UIColor *backColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    UIColor *progressColor = [UIColor orangeColor];
    _progressView = [[CircleProgressView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 70.0) backColor:backColor progressColor:progressColor lineWidth:6];
    _progressView.delegate = self;
    [self addSubview:_progressView];
}

-(void)initLabel{

}
-(void)setProgress:(float)progress{
    NSLog(@"%f",progress);
    _progressView.progress = progress;
    if (progress != 1.0) {

    } else {

    }
}
-(void)setProgress:(float)progress animated:(BOOL)animated{
    _progressView.progress = progress;
    if (progress != 1.0) {
        
    } else {

    }
}
-(void)dealloc{
    [_progressView release];
    _progressView  = nil;
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
