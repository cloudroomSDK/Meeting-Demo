//
//  AppDelegate.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/5.
//

#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "PathUtil.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self _setupConfigure];
    [self _setupMainWindow];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[CloudroomVideoSDK shareInstance] uninit];
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
//    return NO;
//}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag) {
        return NO;
    }
    
    [self.mainWindow.window makeKeyAndOrderFront:nil];
    
    return YES;
}

- (void)_setupMainWindow {
    [[self.mainWindow window] center];
    [[self.mainWindow window] orderFront:nil];
}

- (void)_setupConfigure
{
    [AppDelegate _setupForVideoCallSDK];
}

+ (void)_setupForVideoCallSDK
{
    if([[CloudroomVideoSDK shareInstance] isInitSuccess])
    {
        [[CloudroomVideoSDK shareInstance] uninit];
    }
    
    CRSDKHelper *sdkHelper = [CRSDKHelper shareInstance];
    
    if ([NSString stringCheckEmptyOrNil:sdkHelper.account] ||
        [NSString stringCheckEmptyOrNil:sdkHelper.pswd] ||
        [NSString stringCheckEmptyOrNil:sdkHelper.server]) {
        [sdkHelper resetInfo];
    }
    
    SdkInitDat *sdkInitData = [[SdkInitDat alloc] init];
    CloudroomVideoSDK *cloudroomVideoSDK = [CloudroomVideoSDK shareInstance];

    
    // 设置 SDK 内部使用的文件位置
    [sdkInitData setSdkDatSavePath:[PathUtil searchPathInCacheDir:@"CloudroomVideoSDK"]];
    // 是否在控制台显示 SDK 日志
    [sdkInitData setShowSDKLogConsole:YES];
    [sdkInitData setNoCall:NO];
    [sdkInitData setNoQueue:NO];
    [sdkInitData setNoMediaDatToSvr:NO];
    [sdkInitData setIsMultiDelegate:YES];
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
    CRVIDEOSDK_ERR_DEF error = [cloudroomVideoSDK initSDK:sdkInitData];
    
    if (error != CRVIDEOSDK_NOERR) {
        MLog(@"VideoCallSDK init error!");
        [[CloudroomVideoSDK shareInstance] uninit];
    }

    //设置oss账号
    [[CloudroomVideoSDK shareInstance] setAliyunOssAccountInfo:@"LTAIHJIOQulHaGQv" accessSecret:@"uhofooE515WKKXsTYQ7kNqRE5E19JM"];
    
    // 获取 SDK 版本号
    NSLog(@"GetVideoCallSDKVer:%@", [CloudroomVideoSDK getCloudroomVideoSDKVer]);
}

#pragma mark - Lazy

- (MainWindowController *)mainWindow {
    if (!_mainWindow) {
        _mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    }
    return _mainWindow;
}

@end
