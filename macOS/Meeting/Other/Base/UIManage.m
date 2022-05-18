//
//  UIManage.m
//  Record(all)
//
//  Created by LyuBook on 2019/12/26.
//  Copyright © 2019 CloudRoom. All rights reserved.
//

#import "UIManage.h"

@implementation UIManage

+ (instancetype)shareInstance {
    static UIManage *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[UIManage alloc] init];
    });
    return singleton;
}

- (NSString *)getCurDirString {
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSInteger curYear = [[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    NSInteger curMonth = [[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"dd"];
    NSInteger curDay = [[formatter stringFromDate:date] integerValue];
    
    return [NSString stringWithFormat:@"%04zd-%02zd-%02zd", curYear, curMonth, curDay];
}

@end
