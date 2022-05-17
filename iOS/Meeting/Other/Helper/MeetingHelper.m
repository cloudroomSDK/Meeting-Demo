//
//  MeetingHelper.m
//  Meeting
//
//  Created by king on 2017/2/10.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "MeetingHelper.h"

static NSString * const MeetingHelper_server = @"server";
static NSString * const MeetingHelper_account = @"account";
static NSString * const MeetingHelper_pswd = @"pswd";
static NSString * const MeetingHelper_nickname = @"nickname";
static NSString * const MeetingHelper_datEncType = @"datEncType";

@interface MeetingHelper ()

@property (nonatomic, copy, readwrite) NSString *server; /**< 服务器地址 */
@property (nonatomic, copy, readwrite) NSString *account; /**< 账户 */
@property (nonatomic, copy, readwrite) NSString *pswd; /**< 密码 */
@property (nonatomic, copy, readwrite) NSString *nickname; /**< 登录昵称 */
@property (nonatomic, copy, readwrite) NSString *datEncType;

@end

@implementation MeetingHelper
#pragma mark - singleton
static MeetingHelper *shareInstance;
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
    
    return self;
}

#pragma mark - public method
- (void)writeAccount:(NSString *)account pswd:(NSString *)pswd server:(NSString *)server datEncType:(NSString*)datEncType
{
    _account = account;
    _pswd = pswd;
    _server = server;
    self.datEncType = datEncType;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_account forKey:MeetingHelper_account];
    [userDefaults setObject:_pswd forKey:MeetingHelper_pswd];
    [userDefaults setObject:_server forKey:MeetingHelper_server];
    [userDefaults setObject:_datEncType forKey:MeetingHelper_datEncType];
    [userDefaults synchronize];
}

- (void)writeNickname:(NSString *)nickname
{
    _nickname = nickname;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_nickname forKey:MeetingHelper_nickname];
    [userDefaults synchronize];
}

- (void)readInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _server = [userDefaults stringForKey:MeetingHelper_server];
    _account = [userDefaults stringForKey:MeetingHelper_account];
    _pswd = [userDefaults stringForKey:MeetingHelper_pswd];
    _nickname = [userDefaults stringForKey:MeetingHelper_nickname];
    self.datEncType = [userDefaults stringForKey:MeetingHelper_datEncType];
    if([self.datEncType checkEmptyOrNil] || self.datEncType.intValue < 0) {
        self.datEncType = @"1";
    }
}

- (void)resetInfo;
{
    [self writeAccount:@"demo@cloudroom.com" pswd:@"123456" server:@"sdk.cloudroom.com" datEncType:@"1"];
    [self readInfo];
}
@end
