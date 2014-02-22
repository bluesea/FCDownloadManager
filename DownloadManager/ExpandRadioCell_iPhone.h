//
//  ExpandRadioCell_iPhone.h
//  Tangyou
//
//  Created by Ping on 14-1-6.
//  Copyright 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface ExpandRadioCell_iPhone : UITableViewCell
{

}
@property (nonatomic,retain)IBOutlet UIButton *downBtn;
@property (retain, nonatomic) IBOutlet UILabel *radioNameL;
@property(nonatomic,assign)CSTaskStatus status;

+ (ExpandRadioCell_iPhone*)cell;

@end
