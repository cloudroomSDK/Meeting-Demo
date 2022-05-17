//
//  MeetingBtn.m
//  Meeting
//
//  Created by king on 2017/11/14.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "MeetingBtn.h"

// 相关宏定义
#define kRightButtonRatio 0.7
#define kRightButtonWidth self.bounds.size.width
#define kRightButtonHeight self.bounds.size.height

@implementation MeetingBtn
#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubViews];
    }
    
    return self;
}

#pragma mark - private method
- (void)initSubViews {
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
}

#pragma mark - reload methods
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageWidth = kRightButtonWidth;
    CGFloat imageHeight = kRightButtonHeight * kRightButtonRatio;
    CGFloat imageY = 0;
    CGFloat imageX = 0; // (self.bounds.size.width - imageWidth) * kRightButtonRatio;
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0.0f;
    CGFloat titleY = kRightButtonHeight * kRightButtonRatio;
    CGFloat titleWidth = kRightButtonWidth;
    CGFloat titleHeight = kRightButtonHeight * (1 - kRightButtonRatio);
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}
@end
