//
//  TimeUtil.m
//  VideoCall
//
//  Created by king on 2016/12/14.
//  Copyright © 2016年 CloudRoom. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil
#pragma mark - public method
+ (NSString *)getFormatTimeString:(NSInteger)seconds
{
    if (seconds > NSIntegerMax) {
        return @"范围越界";
    }
    
    NSInteger second = seconds % 60;
    NSInteger minus = seconds / 60 % 60;
    NSInteger hour = seconds / 60 / 60;
    NSMutableString *result = [NSMutableString string];
    
    if (hour > 0) {
        [result appendString:[NSString stringWithFormat:@"%zd时", hour]];
    }
    
    if (minus > 0) {
        [result appendString:[NSString stringWithFormat:@"%zd分", minus]];
    }
    
    if (second >= 0) {
        [result appendString:[NSString stringWithFormat:@"%zd秒", second]];
    }
    
    return [result copy];
}
@end
