//
//  NSArray+K.m
//  CallBar
//
//  Created by apple on 15/7/3.
//  Copyright (c) 2015年 CloudRoom. All rights reserved.
//

#import "NSArray+K.h"

@implementation NSArray (K)
#pragma mark - public methods
+ (BOOL)arrayCheckEmptyOrNil:(NSArray *)aArray
{
    return aArray == nil ? YES : [aArray checkEmptyOrNil];
}

#pragma mark - private methods
- (BOOL)checkEmptyOrNil
{
    return [self count] <= 0 ? YES : NO;
}

@end
