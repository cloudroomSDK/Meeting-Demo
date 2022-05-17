//
//  PSTopView.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PSTopView.h"

@interface PSTopView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *saveBtn;

- (IBAction)clickBtnForPSTopView:(UIButton *)sender;

@end

@implementation PSTopView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - selector
- (IBAction)clickBtnForPSTopView:(UIButton *)sender {
    if (_response) {
        _response(self, sender);
    }
}

#pragma mark - private method
- (void)_commonSetup {
    self.backgroundColor = UIColorFromRGBA(57, 171, 251, 1.0);
    
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
@end
