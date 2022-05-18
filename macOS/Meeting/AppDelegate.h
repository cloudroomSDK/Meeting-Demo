//
//  AppDelegate.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/5.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "MeetingWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) MainWindowController *mainWindow;

+ (void)_setupForVideoCallSDK;

@end

