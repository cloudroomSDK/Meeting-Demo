//
//  MessageCellView.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import "MessageCellView.h"
#import "MChatModel.h"

@implementation MessageCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.messageLabel.wantsLayer = YES;
    self.messageLabel.layer.cornerRadius = 5;
    self.messageLabel.layer.borderWidth = 1.0;
    self.messageLabel.layer.borderColor = [NSColor systemGrayColor].CGColor;
    
    
}

#pragma mark - public method
+ (CGFloat)heightForModel:(MChatModel *)model maxWidth:(CGFloat)maxWidth font:(NSFont *)font {
    CGFloat height = [[NSString stringWithFormat:@"[%@]\n%@", model.name, model.content] boundingRectWithSize:NSMakeSize(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:NULL].size.height;
    return height;
}

@end
