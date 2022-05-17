//
//  MTwoView.h
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTwoOneView, MTwoTwoView;

@interface MTwoView : UIView

@property (nonatomic, weak) IBOutlet MTwoOneView *twoOneView;
@property (nonatomic, weak) IBOutlet MTwoTwoView *twoTwoView;

@end
