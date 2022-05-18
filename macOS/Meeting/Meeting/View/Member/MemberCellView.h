//
//  MemberCellView.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MemberCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSButton *microphoneButton;
@property (weak) IBOutlet NSButton *videoButton;
@property (nonatomic, strong) MemberInfo *member;

@end

NS_ASSUME_NONNULL_END
