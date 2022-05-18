//
//  InputMediaUrlWindowController.h
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/12/15.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputMediaUrlWindowController : NSWindowController
@property (nonatomic, copy) void (^openMediaUrlBlock)(void);
@end

NS_ASSUME_NONNULL_END
