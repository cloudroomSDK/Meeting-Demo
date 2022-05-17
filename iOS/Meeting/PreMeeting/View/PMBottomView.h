//
//  PMBottomView.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMBottomView;

typedef void (^PMBottomViewResponse)(PMBottomView *view, UIButton *sender, NSString *inputText);

typedef NS_ENUM(NSUInteger, PMBottomViewBtnType) {
    PMBottomViewBtnTypeEnter,
    PMBottomViewBtnTypeCreate
};

@interface PMBottomView : UIView

@property (nonatomic, copy) PMBottomViewResponse response;

@end
