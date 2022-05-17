//
//  MTopView.m
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MTopView.h"

@interface MTopView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UITableView *chatView;

@end

@implementation MTopView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - public method
- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)showAnimation {
    if (self.alpha == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            [MTopView cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenAnimation) object:nil];
            [self performSelector:@selector(hiddenAnimation) withObject:nil afterDelay:5];
        }];
    }
}

- (void)hiddenAnimation {
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        }];
    }
}

#pragma mark - private method
- (void)_commonSetup {
    self.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.5);
    self.alpha = 0;
    
    
}
@end
