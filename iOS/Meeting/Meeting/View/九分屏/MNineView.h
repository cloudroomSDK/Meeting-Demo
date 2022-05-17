//
//  MNineView.h
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNineOneView, MNineTwoView, MNineThreeView, MNineFourView, MNineFiveView, MNineSixView, MNineSevenView, MNineEgihtView, MNineNineView;

@interface MNineView : UIView

@property (nonatomic, weak) IBOutlet MNineOneView *nineOneView;
@property (nonatomic, weak) IBOutlet MNineTwoView *nineTwoView;
@property (nonatomic, weak) IBOutlet MNineThreeView *nineThreeView;
@property (nonatomic, weak) IBOutlet MNineFourView *nineFourView;
@property (nonatomic, weak) IBOutlet MNineFiveView *nineFiveView;
@property (nonatomic, weak) IBOutlet MNineSixView *nineSixView;
@property (nonatomic, weak) IBOutlet MNineSevenView *nineSevenView;
@property (nonatomic, weak) IBOutlet MNineEgihtView *nineEightView;
@property (nonatomic, weak) IBOutlet MNineNineView *nineNineView;

@end
