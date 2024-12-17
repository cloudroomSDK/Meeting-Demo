//
//  AppDelegate.m
//  Meeting
//
//  Created by king on 2017/2/9.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "IQKeyboardManager.h"
#import "PathUtil.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupConfigure];
     [Bugly startWithAppId:@"fcd7647814"];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FIXME:应用退出崩溃 added by king 201803091647
    [[CloudroomVideoSDK shareInstance] uninit];
}

#pragma mark - private method
- (void)setupConfigure
{
    [self _setupForStatusBar];

//    static int time = 1;
//    while (1) {
//        sleep(2);
//        
//        time++;
//    }
    
    [AppDelegate _setupForVideoCallSDK];
    
    [self _setupForIQKeyboard];
}

- (void)_setupForStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

+ (void)_setupForVideoCallSDK
{

    if([[CloudroomVideoSDK shareInstance] isInitSuccess])
    {
        [[CloudroomVideoSDK shareInstance] uninit];
    }
    
    CRSDKHelper* sdkHelper = [CRSDKHelper shareInstance];
    
    // FIXME:WARNING: QApplication was not created in the main() thread.QObject::connect: No such slot MeetRecordImpl::slot_SetScreenShare(bool)
    SdkInitDat *sdkInitData = [[SdkInitDat alloc] init];
    // TODO:必须指定日志文件路径,才能产生日志文件,并能够上传 added by king 201711061904
    [sdkInitData setSdkDatSavePath:[PathUtil searchPathInCacheDir:@"CRVideoSDK"]];
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    [sdkInitData setSdkDatSavePath:docDir];
    [sdkInitData setShowSDKLogConsole:YES];
    int datEncTypeInt = sdkHelper.datEncType.intValue;
    sdkInitData.datEncType = datEncTypeInt >= 1 ? @"1" : @"0";
    if(datEncTypeInt == 1) {
        [sdkInitData.params setValue:@"1" forKey:@"VerifyHttpsCert"];
    } else {
        [sdkInitData.params setValue:@"0" forKey:@"VerifyHttpsCert"];
    }
    NSString* rsaPublicKey = sdkHelper.rsaPublicKey;
    if([rsaPublicKey length] <= 0) {
        [sdkInitData.params setValue:@"0" forKey:@"HttpDataEncrypt"];
    } else {
        [sdkInitData.params setValue:@"1" forKey:@"HttpDataEncrypt"];
        [sdkInitData.params setValue:rsaPublicKey forKey:@"RsaPublicKey"];
    }
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoSDK shareInstance] initSDK:sdkInitData];
    
    if (error != CRVIDEOSDK_NOERR) {
        MLog(@"CloudroomVideoSDK init error!");
        [[CloudroomVideoSDK shareInstance] uninit];
    }
    
    MLog(@"GetCloudroomVideoSDKVer:%@", [CloudroomVideoSDK getCloudroomVideoSDKVer]);
}

// FIXME:修改键盘ToolBar按钮标题
- (void)_setupForIQKeyboard
{
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:@"完成"];
}

@end
