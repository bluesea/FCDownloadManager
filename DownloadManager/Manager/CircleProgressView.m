//
//  CircleProgressView.m
//  Tangyou
//
//  Created by Ping on 14-2-20.
//
//

#import "CircleProgressView.h"
#import <QuartzCore/QuartzCore.h>


@implementation CircleProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _backColor = [backColor retain];
        _progressColor = [progressColor retain];
        _lineWidth = lineWidth;
        _percentLabel = [[UILabel alloc]init];
        [_percentLabel setFrame:CGRectMake(0, 0, 30, 30)];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.center = self.center;
        _percentLabel.font = Font(10);
        _percentLabel.textColor = [UIColor orangeColor];
        [self addSubview:_percentLabel];
    }
    
    return self;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //draw background circle
    NSLog(@"%f",self.bounds.size.width / 2 - self.lineWidth / 2);
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                              radius:self.bounds.size.width / 3 - self.lineWidth / 2
                                                          startAngle:(CGFloat) - M_PI_2
                                                            endAngle:(CGFloat)(1.5 * M_PI)
                                                           clockwise:YES];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (self.progress != 0) {
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                                      radius:self.bounds.size.width / 3 - self.lineWidth / 2
                                                                  startAngle:(CGFloat) - M_PI_2
                                                                    endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI)
                                                                   clockwise:YES];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
    if (self.progress == 1) {
        _percentLabel.text = [NSString stringWithFormat:@"已下载"];
    }else{
        _percentLabel.text = [NSString stringWithFormat:@"%.0f%%",self.progress*100];
    }
}

@end
