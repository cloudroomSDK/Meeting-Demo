//
//  MChatView.m
//  Meeting
//
//  Created by king on 2018/7/5.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MChatView.h"
#import "MChatCell.h"
#import "MChatModel.h"
#import "Masonry.h"

@interface MChatView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UIView *topView; /**< 顶部视图 包含: tableView */
@property (nonatomic, strong) UILabel *titleLabel; /**< 房间 ID */
@property (nonatomic, strong) UITableView *tableView; /**< 消息列表视图 */
@property (nonatomic, strong) MChatCell *tempCell; /**< 消息视图 */
@property (nonatomic, strong) UIView *bottomView; /**< 输入视图 包含: downBtn + inputTextField */
@property (nonatomic, strong) UIButton *downBtn; /**< 键盘弹下按钮 */
@property (nonatomic, strong) UITextField *inputTextField; /**< 输入框 */
@property (nonatomic, assign) BOOL keyboardShow;

@end

@implementation MChatView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self _commonSetup];
    
    return self;
}

- (void)dealloc {
    NSLog(@"ChatView dealloc");
    
    [self _removeNotifications];
}

#pragma mark - public method
- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)showAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hideAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }];
}

- (void)clickShow {
    if (![_inputTextField isFirstResponder]) {
        [_inputTextField becomeFirstResponder];
    }
}

- (BOOL)isShow {
    return self.alpha == 1;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MChatModel *model = [self.message objectAtIndex:indexPath.row];
    
    if (model.cacheH == 0) {
        model.cacheH = [_tempCell heightForModel:model];
    }
    return model.cacheH;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.message.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MChatModel"];
    
    if (!cell) {
        cell = [[MChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MChatModel"];
    }
    
    [self _configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - selector
- (void)clickBtnForChatView:(UIButton *)sender {
    if (_inputTextField.isFirstResponder) {
        [_inputTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length <= 0) {
        [HUDUtil hudShow:@"请输入内容" delay:3 animated:YES];
        return YES;
    }
    
    if (_textFieldShouldReturn) {
        _textFieldShouldReturn(self, textField.text);
    }
    
    textField.text = nil;
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (![self isShow]) {
        [self showAnimation];
    }
    
    NSLog(@"keyboardWillShow notification.userInfo:%@", notification.userInfo);
    
    _keyboardShow = YES;
    
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat interval = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.superview);
        make.bottom.equalTo(self.superview).offset(-(height));
    }];
    
    // FIXME: 聊天内容显示位置和设计图不符 (king 20180719)
    if (_topView && _bottomView) {
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bottomView.mas_top).offset(0);
        }];
    }
    
    [UIView animateWithDuration:interval animations:^{
        [self.superview setNeedsLayout];
        [self.superview layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide notification.userInfo:%@", notification.userInfo);
    
    _keyboardShow = NO;
    
    CGFloat interval = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.superview);
    }];
    
    if (_topView && _bottomView) {
        [_topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bottomView.mas_top).offset(-124);
        }];
    }
    
    [UIView animateWithDuration:interval animations:^{
        [self.superview setNeedsLayout];
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}

#pragma mark - private method
- (void)_commonSetup {
    // bottom
    UIView *bottomView = [[UIView alloc] init];
    // 设置约束的前提: 先添加到父控件上
    [self addSubview:bottomView];
    bottomView.backgroundColor = [UIColor whiteColor];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    _bottomView = bottomView;

    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downBtn setImage:[UIImage imageNamed:@"meeting_keyboard_down"] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(clickBtnForChatView:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:downBtn];
    [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(bottomView);
        make.width.height.mas_equalTo(44);
    }];
    _downBtn = downBtn;

    UITextField *inputTextField = [[UITextField alloc] init];
    inputTextField.borderStyle = UITextBorderStyleNone;
    inputTextField.placeholder = @"聊点什么？";
    inputTextField.returnKeyType = UIReturnKeySend;
    inputTextField.delegate = self;
    [bottomView addSubview:inputTextField];
    [inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(downBtn.mas_right).offset(8);
        make.right.top.bottom.equalTo(bottomView);
    }];
    _inputTextField = inputTextField;

    // top
    UIView *topView = [[UIView alloc] init];
    [self addSubview:topView];
    topView.backgroundColor = [UIColor clearColor];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(bottomView.mas_top).offset(-124);
    }];
    _topView = topView;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(20);
        make.left.right.equalTo(topView);
        make.height.mas_equalTo(44);
    }];
    _titleLabel = titleLabel;

    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [topView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.bottom);
        make.left.bottom.right.equalTo(topView);
    }];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 20;
    tableView.allowsSelection = NO;
    [contentView addSubview:tableView];
    [tableView registerClass:[MChatCell class] forCellReuseIdentifier:@"MChatCell"];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        // make.center.mas_equalTo(contentView.center);
        make.left.right.bottom.equalTo(contentView);
        make.height.mas_equalTo(128);
    }];
    _tableView = tableView;
    _tempCell = [[MChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MChatCell"];
    
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0;
    
    _keyboardShow = NO;
    
    [self _registerNotifications];
}

- (void)_registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)_removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_configureCell:(MChatCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.model = self.message[indexPath.row];
}

- (void)_scrollToBottomisAnimated:(BOOL)isAnimated {
    if (self.message == 0) {
        return;
    }
    
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.message.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:isAnimated];
    });
}

#pragma mark - getter & setter
- (void)setMessage:(NSArray<MChatModel *> *)message {
    _message = message;
    // 刷新数据
    [_tableView reloadData];
    // FIXME: IM 聊天记录可能不滚动到最后一行 (king 20180719)
    [self _scrollToBottomisAnimated:YES];
}

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_keyboardShow) {
        [super touchesBegan:touches withEvent:event];
    }
}
@end
