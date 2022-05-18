//
//  RecordHelper.m
//  Record
//
//  Created by king on 2017/6/9.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import "RecordHelper.h"
#import "AppDelegate.h"

static NSString * const KEY_server = @"server";
static NSString * const KEY_account = @"account";
static NSString * const KEY_pswd = @"pswd";
static NSString * const KEY_nickname = @"nickname";
static NSString * const KEY_rsaPublicKey = @"rsaPublicKey";

@interface RecordHelper ()

@end

@implementation RecordHelper
#pragma mark - singleton
static RecordHelper *shareInstance;
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
    
    // 争取应用在后台能多运行170s左右
    // [self _addNotifications];
    
    return self;
}

- (void)dealloc
{
    [self _removeNotifications];
}

#pragma mark - selector
- (void)appDidEnterBackground:(NSNotification *)notification
{
    MLog(@"");
    [self _doSomethingOnBackGround];
}

- (void)appWillEnterForeground:(NSNotification *)notification
{
    MLog(@"");
}

#pragma mark - public method
- (void)writeAccount:(NSString *)account pswd:(NSString *)pswd server:(NSString *)server rsaPublicKey:(NSString*)rsaPublicKey
{
    BOOL needReInit = ![_rsaPublicKey isEqualToString:rsaPublicKey];
    _account = account;
    _server = server;
    _pswd = pswd;
    _rsaPublicKey = rsaPublicKey;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_account forKey:KEY_account];
    [userDefaults setObject:_pswd forKey:KEY_pswd];
    [userDefaults setObject:_server forKey:KEY_server];
    [userDefaults setObject:_rsaPublicKey forKey:KEY_rsaPublicKey];
    
    [userDefaults synchronize];
    if(needReInit) {
        [[CloudroomVideoMgr shareInstance] logout];
        [AppDelegate _setupForVideoCallSDK];
    }
}

- (void)writeNickname:(NSString *)nickname
{
    _nickname = nickname;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_nickname forKey:KEY_nickname];
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
}

- (void)resetInfo;
{
    [self writeAccount:@"demo@cloudroom.com" pswd:@"123456" server:@"www.cloudroom.com" rsaPublicKey:@"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAI/Wu/TXQlcLmW5Yxh99W1S76X4X4QSx5F6OhMIiZ/q8z3Wc0Q69udgaJrQR+AREGquyO61By6TieeiyaaGWKAsCAwEAAQ=="];
    [self readInfo];
}

#pragma mark - private method
- (void)_addNotifications
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appDidEnterBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appWillEnterForeground:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
}

- (void)_removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**< 后台处理 */
- (void)_doSomethingOnBackGround
{
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    
//    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
//    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        // Clean up any unfinished task business by marking where you
//        // stopped or ending the task outright.
//        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
    
    // do something enter background
}
@end
