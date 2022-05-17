//
//  MChatView.h
//  Meeting
//
//  Created by king on 2018/7/5.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MChatView, MChatModel;

typedef void (^MChatViewTextFieldShouldReturn) (MChatView *chatView, NSString *text);

@interface MChatView : UIView

@property (nonatomic, copy) NSArray<MChatModel *> *message; /**< 消息列表 */
@property (nonatomic, copy) MChatViewTextFieldShouldReturn textFieldShouldReturn; /**< "发送"按钮响应 */

- (void)setTitle:(NSString *)title;
- (void)showAnimation;
- (void)hideAnimation;
- (void)clickShow;
- (BOOL)isShow;

@end
