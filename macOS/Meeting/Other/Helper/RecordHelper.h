//
//  RecordHelper.h
//  Record
//
//  Created by king on 2017/6/9.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordHelper : NSObject

@property (nonatomic, copy, readonly) NSString *server; /**< 服务器地址 */
@property (nonatomic, copy, readonly) NSString *account; /**< 账户 */
@property (nonatomic, copy, readonly) NSString *pswd; /**< 密码 */
@property (nonatomic, copy, readonly) NSString *nickname; /**< 登录昵称 */

@property (nonatomic, copy, readonly) NSString *rsaPublicKey;

+ (instancetype)shareInstance;


/**
 写 账号/密码/服务器地址 信息
 @param account 账号
 @param pswd 密码
 @param server 服务器地址
 */
- (void)writeAccount:(NSString *)account pswd:(NSString *)pswd server:(NSString *)server rsaPublicKey:(NSString*)rsaPublicKey;

/**
 写 昵称

 @param nickname 昵称
 */
- (void)writeNickname:(NSString *)nickname;

/**
 读取信息(账号/密码/服务器地址/昵称)
 */
- (void)readInfo;

/**
 恢复默认值(不包括 昵称)
 */
- (void)resetInfo;

@end
