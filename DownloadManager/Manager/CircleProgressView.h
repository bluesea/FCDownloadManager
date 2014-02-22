//
//  CircleProgressView.h
//  Tangyou
//
//  Created by Ping on 14-2-20.
//
//

#import <UIKit/UIKit.h>
@protocol CircularProgressDelegate;

@interface CircleProgressView : UIView
@property (retain, nonatomic) UIColor *backColor;
@property (retain, nonatomic) UIColor *progressColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) float progress;
@property (retain, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id <CircularProgressDelegate> delegate;
@property (retain, nonatomic) UILabel *percentLabel;
- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;
@end


@protocol CircularProgressDelegate <NSObject>

- (void)didUpdateProgressView;

@end