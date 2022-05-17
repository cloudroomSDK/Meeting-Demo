//
//  MBottomView.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MBottomViewBtnType) {
    MBottomViewBtnTypeMic, // 开 / 关 麦克风
    MBottomViewBtnTypeCamera, // 开 / 关 摄像头
    MBottomViewBtnTypeChat, // 聊天
    MBottomViewBtnTypeExCamera, // 切换摄像头
    MBottomViewBtnTypeRatio, // 分辨率
    MBottomViewBtnTypeExit, // 退出
    MBottomViewBtnTypeFrame // 帧率
};

@class MeetingBtn, MBottomView;

typedef void (^MBottomViewResponse)(MBottomView *view, UIButton *sender);

@interface MBottomView : UIView

@property (nonatomic, copy) MBottomViewResponse response;

- (void)updateMic:(BOOL)selected;
- (void)updateCamera:(BOOL)selected;

@end
