//
//  NSString+K.h
//  SearchContacts
//
//  Created by apple on 14/11/11.
//  Copyright (c) 2014年 TJF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (K)

/**
 *  判断指定的字符串对象是否为空
 *
 *  @param aString 指定字符串
 *
 *  @return YES/NO
 */
+ (BOOL)stringCheckEmptyOrNil:(NSString *)aString;
- (BOOL)checkEmptyOrNil;

+ (BOOL)stringCheckEmptyWhiteSpaceOrNil:(NSString *)aString;
- (BOOL)checkEmptyWhiteSpaceOrNil;

/**
 *  是否以数字或其他字符(A~Z或者a~z以外的字符)开头
 *
 *  @param aString 指定字符串
 *
 *  @return YES/NO
 */
+ (BOOL)startWithoutHanYuAndAlpha:(NSString *)aString;

/**
 *  字符串转数组
 *
 *  @param astring 指定字符串
 *
 *  @return 转换后的数组
 */
+ (NSArray *)translateToArrayFromString:(NSString *)astring;

/**
 *  是否包含子串
 *
 *  @param astring 指定子串
 *
 *  @return YES/NO
 */
- (BOOL)containsWithString:(NSString *)astring;

/**
 *  计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 *  @return 文字高度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 *  @return 文字宽度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 *  计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 *  @return 文字大小
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 *  @return 文字大小
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

+ (NSString *)stringFromHexString:(NSString *)hexString;
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 *  MD5加密
 *  参考:iOS MD5加密(https://www.jianshu.com/p/8898b0bb3c94)
 *  @param inStr   给定的字符串
 *
 *  @return 经过MD5加密后的字符串(小写)
 */
+ (NSString *)md5:(NSString *)inStr;

/**
 *  MD5加密
 *
 *  @param inStr   给定的字符串
 *
 *  @return 经过MD5加密后的字符串(大写)
 */
+ (NSString *)MD5:(NSString *)inStr;

@end
