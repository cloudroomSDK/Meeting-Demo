//
//  PreSettingsController.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PreSettingsController.h"
#import "PSTopView.h"
#import "PSBottomView.h"
#import "MRatioView.h"
#import "PMRoundBtn.h"
#import "CRSDKHelper.h"
#import "PMRoundTextField.h"
#import "NSString+K.h"
#import "SDKUtil.h"
#import "AppDelegate.h"
#import "AppConfig.h"

NSString *const kAppIDDefaultShow = @"默认appID";
NSString *const kAppIDPlaceholder = @"请配置appID";

@interface PreSettingsController ()

@property (weak, nonatomic) IBOutlet PSBottomView *bottomView;

@property (weak, nonatomic) IBOutlet MRatioView *datEncTypeView;

@end

@implementation PreSettingsController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _commonSetup];
}

- (IBAction)saveAction:(id)sender {
    [self _handleSave];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)_commonSetup {
    [self _setupProperty];
}

- (void)_setupProperty {
    weakify(self)
    [_bottomView setResponse:^(PSBottomView *view, UIButton *sender) {
        strongify(wSelf)
        if(sender == view.reset) {
            [sSelf _handleReset];
        } else if(sender == view.datEncTypeBtn) {
            [self.datEncTypeView showAnimation];
//            self.datEncTypeView.hidden = !self.datEncTypeView.hidden;
        }
    }];
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    [self.datEncTypeView hiddenAnimation];
    self.datEncTypeView.dataSource = @[@"http", @"https(CA证书)", @"https(自有SSL证书)"];
    self.datEncTypeView.curRatio = [self.datEncTypeView.dataSource objectAtIndex:meetingHelper.datEncType.integerValue];
    [self.datEncTypeView setResponse:^(MRatioView *view, UIButton *sender, NSString *value) {
        switch ([sender tag]) {
            case MRatioViewBtnTypeCancel: break;
            case MRatioViewBtnTypeDone: [_bottomView.datEncTypeBtn setTitle:value forState:UIControlStateNormal]; break;
        }
    }];
    
    if ([NSString stringCheckEmptyOrNil:meetingHelper.account] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.pswd] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.server] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.datEncType]) {
        [self _handleReset];
    } else {
        [self reloadConfigView];
    }
}

- (void)_handleSave {
    NSString *server = [_bottomView.serverTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *account = _bottomView.userTextField.text;
    NSString *pswd = _bottomView.paswdTextField.text;
    NSString* rsaPublicKey = _bottomView.rsaTextField.text;
        
    NSUInteger datEncType = [self.datEncTypeView.dataSource indexOfObject:_bottomView.datEncTypeBtn.currentTitle];
    if(datEncType < 0) {
        return;
    }
    if ([NSString stringCheckEmptyOrNil:server]) {
        [HUDUtil hudShow:@"服务器地址不能为空!" delay:3 animated:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:account]) {
        [HUDUtil hudShow:@"用户名不能为空!" delay:3 animated:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:pswd]) {
        [HUDUtil hudShow:@"密码不能为空!" delay:3 animated:YES];
        return;
    }
    // 不保存默认展示
    if ([account isEqualToString:kAppIDDefaultShow] || [account isEqualToString:KDefaultAppID]) {
        account = nil;
        pswd = nil;
    }
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper writeAccount:account pswd:pswd server:server datEncType:[NSString stringWithFormat:@"%lu", (unsigned long)datEncType]];
    meetingHelper.rsaPublicKey = rsaPublicKey;
    
    [[CloudroomVideoMgr shareInstance] logout];
    [AppDelegate _setupForVideoCallSDK];
}

- (void)_handleReset {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper resetInfo];
    
    [self reloadConfigView];
}

- (void)reloadConfigView {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    if ([KDefaultAppID isEqualToString:meetingHelper.account] && KDefaultAppID.length > 0) {
        _bottomView.userTextField.text = kAppIDDefaultShow;
    } else {
        _bottomView.userTextField.text = meetingHelper.account;
    }
    _bottomView.serverTextField.text = meetingHelper.server;
    _bottomView.paswdTextField.text = meetingHelper.pswd;
    _bottomView.rsaTextField.text = meetingHelper.rsaPublicKey;
    NSString* value = [self.datEncTypeView.dataSource objectAtIndex:meetingHelper.datEncType.integerValue];
    [_bottomView.datEncTypeBtn setTitle:value forState:UIControlStateNormal];
}

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
