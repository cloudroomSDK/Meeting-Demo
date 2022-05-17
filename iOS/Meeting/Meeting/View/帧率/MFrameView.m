//
//  MFrameView.m
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MFrameView.h"

@interface MFrameView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *titleView; /**< 头部 */
@property (nonatomic, weak) IBOutlet UIButton *cancelBtn; /**< 取消 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel; /**< 头部标题 */
@property (nonatomic, weak) IBOutlet UIButton *doneBtn; /**< 确定 */
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView; /**< 选择器 */

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dataMap;

- (IBAction)clickBtnForMFrameView:(UIButton *)sender;

@end

@implementation MFrameView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - public method
- (void)showAnimation {
    // 选中当前选项
    NSNumber *value = [_dataMap objectForKey:_curFrame];
    NSUInteger index = value.unsignedIntegerValue;
    [_pickerView selectRow:index inComponent:0 animated:YES];
    
    if (self.alpha == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
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

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.bounds.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.text = [_dataSource objectAtIndex:row];
    contentLabel.font = [UIFont systemFontOfSize:18];
    return contentLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _curFrame = [self.dataSource objectAtIndex:row];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_dataSource count];
}

#pragma mark - selector
- (IBAction)clickBtnForMFrameView:(UIButton *)sender {
    if (_response) {
        _response(self, sender, _curFrame);
    }
    
    [self hiddenAnimation];
}

#pragma mark - private method
- (void)_commonSetup {
    _titleView.backgroundColor = UIColorFromRGBA(246, 246, 246, 1.0);
    
    [_cancelBtn setTitleColor:UIColorFromRGBA(213, 213, 213, 1.0) forState:UIControlStateNormal];
    
    [_doneBtn setTitleColor:UIColorFromRGBA(57, 171, 251, 1.0) forState:UIControlStateNormal];
    
    self.alpha = 0;
}

#pragma getter & setter
- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    _dataSource = dataSource;
    
    _dataMap = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < dataSource.count; i++) {
        [_dataMap setObject:@(i) forKey:dataSource[i]];
    }
}
@end
