//
//  PMTopView.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMTopView;

typedef NS_ENUM(NSUInteger, PMTopViewBtnType) {
    PMTopViewBtnTypeSettings
};

typedef void (^PMTopViewResponse)(PMTopView *view, UIButton *sender);

@interface PMTopView : UIView

@property (nonatomic, copy) PMTopViewResponse response;

@end
