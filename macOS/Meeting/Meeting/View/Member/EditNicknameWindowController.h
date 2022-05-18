//
//  EditNicknameWindowController.h
//  Meeting
//
//  Created by YunWu01 on 2021/12/17.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditNicknameWindowController : NSWindowController
@property (nonatomic, copy) void (^EditNicknameBlock)(NSString *nickname);
@end

NS_ASSUME_NONNULL_END
