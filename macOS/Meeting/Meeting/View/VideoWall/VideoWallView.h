//
//  VideoWallView.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/6.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class UsrVideoId;

typedef NS_ENUM(NSInteger, MContentViewType) {
    MContentViewType_2 = 2,   // 2分屏
    MContentViewType_4 = 4,   // 4分屏
    MContentViewType_6 = 6,   // 6分屏
};

@interface VideoWallView : NSView

@property (nonatomic, weak) NSView *twoView; /**< 二分屏 */
@property (nonatomic, weak) NSView *fourView; /**< 四分屏 */
@property (nonatomic, weak) NSView *nineView; /**< 九分屏 */
@property (nonatomic, assign) MContentViewType type; /**< 分屏模式 */

- (void)updateUIViews:(NSArray<UsrVideoId *> *)dataSource localer:(NSString *)localer;

@end

NS_ASSUME_NONNULL_END
