//
//  MContentView.h
//  Meeting
//
//  Created by king on 2018/7/2.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UsrVideoId;

typedef NS_ENUM(NSInteger, MContentViewType) {
    MContentViewTypeTwo, // 二分屏
    MContentViewTypeFour, // 四分屏
    MContentViewTypeNine // 九分屏
};

@interface MContentView : UIView

@property (nonatomic, weak) IBOutlet UIView *twoView; /**< 二分屏 */
@property (nonatomic, weak) IBOutlet UIView *fourView; /**< 四分屏 */
@property (nonatomic, weak) IBOutlet UIView *nineView; /**< 九分屏 */
@property (nonatomic, assign) MContentViewType type; /**< 分屏模式 */

@property (nonatomic, assign) BOOL shareStyle; // 标记是否为共享状态

- (void)updateUIViews:(NSArray<UsrVideoId *> *)dataSource localer:(NSString *)localer;

@end
