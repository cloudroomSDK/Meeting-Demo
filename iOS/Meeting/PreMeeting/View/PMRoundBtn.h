//
//  PMRoundBtn.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PMRoundBtnType) {
    PMRoundBtnTypeDark,
    PMRoundBtnTypeLight
};

@interface PMRoundBtn : UIButton

@property (nonatomic, assign) PMRoundBtnType type;
@property (nonatomic, assign) BOOL select;

@end
