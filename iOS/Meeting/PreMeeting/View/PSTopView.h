//
//  PSTopView.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSTopView;

typedef void (^PSTopViewResponse)(PSTopView *view, UIButton *sender);

@interface PSTopView : UIView

@property (nonatomic, copy) PSTopViewResponse response;

@end
