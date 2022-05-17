//
//  RotationUtil.m
//  AGPlayer
//
//  Created by 吴书敏 on 16/8/3.
//  Copyright © 2016年 littledogboy. All rights reserved.
//

#import "RotationUtil.h"

@implementation RotationUtil
#pragma mark - public method
/**
 强制设备旋转方向
q
 @param orientation 旋转方向
 */
+ (void)forceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/**
 是否横屏

 @return YES/NO
 */
+ (BOOL)isOrientationLandscape
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}
@end
