//
//  MessageCellView.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import <Cocoa/Cocoa.h>

@class MChatModel;

NS_ASSUME_NONNULL_BEGIN

@interface MessageCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *messageLabel;

+ (CGFloat)heightForModel:(MChatModel *)model maxWidth:(CGFloat)maxWidth font:(NSFont *)font;

@end

NS_ASSUME_NONNULL_END
