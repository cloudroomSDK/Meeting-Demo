//
//  MNineView.m
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MNineView.h"

@implementation MNineView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - private method
- (void)_commonSetup {
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
}
@end
