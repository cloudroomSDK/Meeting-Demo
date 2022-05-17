//
//  MFrameView.h
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFrameView;

typedef void (^MFrameViewResponse)(MFrameView *view, UIButton *sender, NSString *value);
typedef NS_ENUM(NSUInteger, MFrameViewBtnType) {
    MFrameViewBtnTypeCancel,
    MFrameViewBtnTypeDone
};

@interface MFrameView : UIView

@property (nonatomic, copy) MFrameViewResponse response;  /**< 按钮响应 */
@property (nonatomic, copy) NSArray<NSString *> *dataSource; /**< 数据源 */
@property (nonatomic, strong) NSString *curFrame; /**< 当前分辨率 */

- (void)showAnimation;
- (void)hiddenAnimation;

@end
