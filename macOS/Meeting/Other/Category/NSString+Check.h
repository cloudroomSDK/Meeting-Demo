//
//  NSString+Check.h
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Check)

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

NS_ASSUME_NONNULL_END
