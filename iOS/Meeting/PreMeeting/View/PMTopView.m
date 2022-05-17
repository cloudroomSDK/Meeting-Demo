//
//  PMTopView.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PMTopView.h"

@interface PMTopView ()

@property (nonatomic, weak) IBOutlet UIButton *settingsBtn; /**< 设置 */

- (IBAction)clickBtnForPMTopView:(UIButton *)sender;

@end

@implementation PMTopView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - selector
- (IBAction)clickBtnForPMTopView:(UIButton *)sender {
    if (_response) {
        _response(self, sender);
    }
}

#pragma mark - private method
- (void)_commonSetup {
}
@end
