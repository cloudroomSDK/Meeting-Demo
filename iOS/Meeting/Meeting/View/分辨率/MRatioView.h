//
//  MRatioView.h
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRatioView;

typedef void (^MRatioViewResponse)(MRatioView *view, UIButton *sender, NSString *value);
typedef NS_ENUM(NSUInteger, MRatioViewBtnType) {
    MRatioViewBtnTypeCancel,
    MRatioViewBtnTypeDone
};

@interface MRatioView : UIView

@property (nonatomic, copy) MRatioViewResponse response; /**< 按钮响应 */
@property (nonatomic, copy) NSArray<NSString *> *dataSource; /**< 数据源 */
@property (nonatomic, copy) NSString *curRatio; /**< 当前分辨率 */

- (void)showAnimation;
- (void)hiddenAnimation;

@end
