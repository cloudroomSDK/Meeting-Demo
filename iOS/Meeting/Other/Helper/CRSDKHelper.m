//
//  MeetingHelper.m
//  Meeting
//
//  Created by king on 2017/2/10.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "CRSDKHelper.h"
#import "AppConfig.h"

NSString * const KEY_server = @"server";
NSString * const KEY_account = @"account";
NSString * const KEY_pswd = @"pswd";
NSString * const KEY_nickname = @"nickname";
NSString * const KEY_datEncType = @"datEncType";
NSString * const KEY_rsaPublicKey = @"rsaPublicKey";

@interface CRSDKHelper ()

@property (nonatomic, copy, readwrite) NSString *server; /**< 服务器地址 */
@property (nonatomic, copy, readwrite) NSString *account; /**< 账户 */
@property (nonatomic, copy, readwrite) NSString *pswd; /**< 密码 */

@end

@implementation CRSDKHelper
#pragma mark - singleton
static CRSDKHelper *shareInstance;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
    });
    
    return shareInstance;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    [self readInfo];
    if ([NSString stringCheckEmptyOrNil:self.account] ||
        [NSString stringCheckEmptyOrNil:self.pswd]) {
        _account = KDefaultAppID;
        _pswd = KDefaultAppSecret;
    }
    if ([NSString stringCheckEmptyOrNil:self.server]) {
        [self resetInfo];
    }
    return self;
}

#pragma mark - public method
- (void)writeAccount:(NSString *)account pswd:(NSString *)pswd server:(NSString *)server datEncType:(NSString*)datEncType
{
    if (account.length > 0) _account = account;
    if (pswd.length > 0) _pswd = pswd;
    _server = server;
    self.datEncType = datEncType;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:KEY_account];
    [userDefaults setObject:pswd forKey:KEY_pswd];
    [userDefaults setObject:_server forKey:KEY_server];
    [userDefaults setObject:_datEncType forKey:KEY_datEncType];
    [userDefaults synchronize];
}

- (void)setNickname:(NSString *)nickname
{
    _nickname = nickname;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_nickname forKey:KEY_nickname];
    [userDefaults synchronize];
}

- (void)setRsaPublicKey:(NSString *)rsaPublicKey
{
    _rsaPublicKey = rsaPublicKey;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_rsaPublicKey forKey:KEY_rsaPublicKey];
    [userDefaults synchronize];
}

- (void)readInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _server = [userDefaults stringForKey:KEY_server];
    _account = [userDefaults stringForKey:KEY_account];
    _pswd = [userDefaults stringForKey:KEY_pswd];
    _nickname = [userDefaults stringForKey:KEY_nickname];
    _rsaPublicKey = [userDefaults stringForKey:KEY_rsaPublicKey];
    _datEncType = [userDefaults stringForKey:KEY_datEncType];
    if([self.datEncType checkEmptyOrNil] || self.datEncType.intValue < 0) {
        self.datEncType = @"1";
    }
}

- (void)resetInfo;
{
    [self writeAccount:nil pswd:nil server:@"sdk.cloudroom.com" datEncType:@"1"];
    self.rsaPublicKey = @"";
    [self readInfo];
    _account = KDefaultAppID;
    _pswd = KDefaultAppSecret;
}
@end
