//
//  MFourView.h
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFourOneView, MFourTwoView, MFourThreeView, MFourFourView;

@interface MFourView : UIView

@property (nonatomic, weak) IBOutlet MFourOneView *fourOneView;
@property (nonatomic, weak) IBOutlet MFourTwoView *fourTwoView;
@property (nonatomic, weak) IBOutlet MFourThreeView *fourThreeView;
@property (nonatomic, weak) IBOutlet MFourFourView *fourFourView;

@end
