//
//  PMBottomView.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PMBottomView.h"
#import "PMRoundBtn.h"
#import "PMRoundTextField.h"

@interface PMBottomView () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (nonatomic, weak) IBOutlet PMRoundTextField *inputTextField;
@property (nonatomic, weak) IBOutlet UIView *line;
@property (nonatomic, weak) IBOutlet UILabel *orLabel;
@property (nonatomic, weak) IBOutlet PMRoundBtn *enterBtn;
@property (nonatomic, weak) IBOutlet PMRoundBtn *createBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lineW;

- (IBAction)clickBtnForPMBottomView:(PMRoundBtn *)sender;

@end

@implementation PMBottomView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - selector
- (IBAction)clickBtnForPMBottomView:(PMRoundBtn *)sender {
    if (_response) {
        _response(self, sender, _inputTextField.text);
    }
}

- (void)inputTextChange:(UITextField *)textField {
    _enterBtn.select = textField.text.length > 0;
}

#pragma mark - private method
- (void)_commonSetup {
    _titleLabel.textColor = UIColorFromRGBA(57, 171, 251, 1.0);
    _titleLabel.font = [UIFont systemFontOfSize:24];
    
    _descLabel.textColor = UIColorFromRGBA(102, 102, 102, 1.0);
    _descLabel.font = [UIFont systemFontOfSize:12];
    
    _inputTextField.placeholder = @"请输入房间号";
    _inputTextField.title = @"";
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [_inputTextField addTarget:self action:@selector(inputTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    _enterBtn.type = PMRoundBtnTypeDark;
    _enterBtn.select = NO;
    
    _line.backgroundColor = UIColorFromRGBA(102, 102, 102, 1.0);
    _lineW.constant = 1 / [UIScreen mainScreen].scale;
    
    _orLabel.textColor = UIColorFromRGBA(102, 102, 102, 1.0);
    _orLabel.font = [UIFont systemFontOfSize:12];
    
    _createBtn.type = PMRoundBtnTypeLight;
}
@end
