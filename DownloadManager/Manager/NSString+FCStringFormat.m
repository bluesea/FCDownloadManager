//
//  NSString+FCStringFormat.m
//  DownloadManager
//
//  Created by pingyandong on 14-2-22.
//  Copyright (c) 2014年 平 艳东. All rights reserved.
//

#import "NSString+FCStringFormat.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (FCStringFormat)
//对string进行MD5编码的函数
-(NSString*)md5EncodedString
{
    const char *concat_str = [self UTF8String];
    
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(concat_str, strlen(concat_str), result);
	NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
	return [hash uppercaseString];
}
@end
