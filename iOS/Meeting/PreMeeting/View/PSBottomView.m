//
//  PSBottomView.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PSBottomView.h"
#import "PMRoundTextField.h"
#import "PMRoundBtn.h"

@interface PSBottomView ()

- (IBAction)clickBtnForPSBottomView:(PMRoundBtn *)sender;

@end

@implementation PSBottomView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - selector
- (IBAction)clickBtnForPSBottomView:(PMRoundBtn *)sender {
    if (_response) {
        _response(self, sender);
    }
}

#pragma mark - private method
- (void)_commonSetup {
    _serverTextField.title = @"服务器地址：";
    _userTextField.title =   @"App  ID:";
    _paswdTextField.title =  @"AppSecret:";
    _rsaTextField.title = @"加密密钥:";
    _reset.type = PMRoundBtnTypeLight;
    self.datEncTypeBtn.type = PMRoundBtnTypeDark;
}
@end
