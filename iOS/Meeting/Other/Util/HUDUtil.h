//
//  HUDUtil.h
//  MLive
//
//  Created by 田进峰 on 2017/8/8.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUDUtil : NSObject

/**
 展示进度过程
 @param text 内容
 @param animated 是否动画
 */
+ (void)hudShowProgress:(NSString *)text animated:(BOOL)animated;

/**
 隐藏进度过程
 @param animated 是否动画
 */
+ (void)hudHiddenProgress:(BOOL)animated;

/**
 展示结果
 @param text 内容
 @param delay 延迟几秒隐藏
 @param animated 是否动画
 */
+ (void)hudShow:(NSString *)text delay:(NSTimeInterval)delay animated:(BOOL)animated;

@end
