//
//  MainWindowController.m
//  Meeting(OC)
//
//  Created by YunWu01 on 2021/11/5.
//

#import "MainWindowController.h"
#import "MeetingWindowController.h"
#import "CRSDKHelper.h"
#import "ConfigViewController.h"

const CGFloat kRadius = 10;

@interface MainWindowController () <NSWindowDelegate, CloudroomVideoMgrCallBack>
@property (weak) IBOutlet NSView *meetIDBgView;
@property (weak) IBOutlet NSView *nicknameBgView;
@property (weak) IBOutlet NSButton *enterButton;
@property (weak) IBOutlet NSButton *createButton;
@property (weak) IBOutlet NSTextField *meetIDTF;
@property (weak) IBOutlet NSTextField *nicknameTF;
@property (weak) IBOutlet NSTextField *sdkVerLabel;
@property (nonatomic, assign) BOOL createMeeting;
@property (nonatomic, copy) NSString *meetingID;
@property (nonatomic, strong) MeetingWindowController *meetingWindowController;
@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // 设置代理
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr addMgrCallback:self];
    
    [self setupUI];
    [self _commonSetup];
}

- (void)setupUI {
    self.meetIDBgView.wantsLayer = YES;
    self.meetIDBgView.layer.cornerRadius = kRadius;
    self.meetIDBgView.layer.borderWidth = 1.0;
    self.meetIDBgView.layer.borderColor = [NSColor systemGrayColor].CGColor;
    
    self.nicknameBgView.wantsLayer = YES;
    self.nicknameBgView.layer.cornerRadius = kRadius;
    self.nicknameBgView.layer.borderWidth = 1.0;
    self.nicknameBgView.layer.borderColor = [NSColor systemGrayColor].CGColor;
    
    self.enterButton.wantsLayer = YES;
    self.enterButton.layer.backgroundColor = [NSColor systemBlueColor].CGColor;
    self.enterButton.layer.cornerRadius = kRadius;
    self.enterButton.layer.borderWidth = 1.0;
    self.enterButton.layer.borderColor = [NSColor systemBlueColor].CGColor;
    
    self.createButton.wantsLayer = YES;
    self.createButton.layer.cornerRadius = kRadius;
    self.createButton.layer.borderWidth = 1.0;
    self.createButton.layer.borderColor = [NSColor systemGrayColor].CGColor;
    
    self.sdkVerLabel.stringValue = [NSString stringWithFormat:@"SDKVer：%@", [CloudroomVideoSDK getCloudroomVideoSDKVer]];
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    if (meetingHelper.nickname) {
        self.nicknameTF.stringValue = meetingHelper.nickname;
    }
    
    NSString *meetID = [[NSUserDefaults standardUserDefaults] objectForKey:@"KLastEnterMeetingID"];
    if (meetID.length == 8) {
        self.meetIDTF.stringValue = meetID;
    }
}

#pragma mark - Action

- (IBAction)enterRoomAction:(id)sender {
    [self setButonEnable:NO];
    [self _loginAndEnterMeeting:_meetIDTF.stringValue];
}

- (IBAction)createRoomAction:(id)sender {
    [self setButonEnable:NO];
    [self _loginAndCreateMeeting];
}

- (IBAction)settingAction:(id)sender {
    ConfigViewController *configViewController = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
    
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:CGRectZero styleMask:style backing:NSBackingStoreBuffered defer:YES];
    window.contentMaxSize = window.contentMinSize = configViewController.view.bounds.size;
    window.contentViewController = configViewController;
    window.releasedWhenClosed = NO;
    [window center];
    [window orderFront:nil];
    
    [self.window orderOut:nil];
}

#pragma mark - private method

- (void)setButonEnable:(BOOL)enable {
    [self.enterButton setEnabled:enable];
    [self.createButton setEnabled:enable];
}

- (void)_commonSetup {
    // 设置属性
    [self _setupProperty];

    // SDK版本号
    self.sdkVerLabel.stringValue = [NSString stringWithFormat:@"SDKVer：%@", [CloudroomVideoSDK getCloudroomVideoSDKVer]];

//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
//    [_appVersionLab setText:[NSString stringWithFormat:@"app版本号:%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]]];
    
    if ([CRSDKHelper shareInstance].nickname) {
        self.nicknameTF.stringValue = [CRSDKHelper shareInstance].nickname;
    }
}

/* 设置属性 */
- (void)_setupProperty {
    
}

- (void)_loginAndCreateMeeting {
    _createMeeting = YES;
    [self _handleLogin];
}

- (void)_loginAndEnterMeeting:(NSString *)inputText {
    if ([NSString stringCheckEmptyOrNil:inputText]) {
        [NSAlert alertMessage:@"房间号不能为空"];
        [self setButonEnable:YES];
        return;
    }
    
    if (inputText.length < 8) {
        [NSAlert alertMessage:@"房间号不能小于8位"];
        [self setButonEnable:YES];
        return;
    }
    
    _createMeeting = NO;
    _meetingID = inputText;
    [self _handleLogin];
}

/* 登录 */
- (void)_handleLogin {
        
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    NSString *nickname = self.nicknameTF.stringValue;
    if ([NSString stringCheckEmptyOrNil:nickname]) {
        [NSAlert alertMessage:@"请输入昵称!"];
        [self setButonEnable:YES];
        return;
    }
    
    // 云屋SDK登陆账号,实际开发中,请联系云屋工作人员获取
    NSString *account = meetingHelper.account;
    // 密码通过MD5以后
    NSString *pswd = meetingHelper.pswd;
    // 服务器地址
    NSString *server = meetingHelper.server;
    
    if ([NSString stringCheckEmptyOrNil:server]) {
        [NSAlert alertMessage:@"服务器地址不能为空!"];
        [self setButonEnable:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:account]) {
        [NSAlert alertMessage:@"账号不能为空!"];
        [self setButonEnable:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:pswd]) {
        [NSAlert alertMessage:@"密码不能为空!"];
        [self setButonEnable:YES];
        return;
    }
    
    NSString *md5Pswd = [NSString md5:meetingHelper.pswd];
    
    MLog(@"server:%@ nickname:%@ account:%@ pswd:%@", server, nickname, account, md5Pswd);
    
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    CloudroomVideoSDK *cloudroomVideoSDK = [CloudroomVideoSDK shareInstance];
    
    meetingHelper.nickname = nickname;
    
    // 设置服务器地址
    [cloudroomVideoSDK setServerAddr:server];
    
//    [HUDUtil hudShowProgress:@"正在登录中..." animated:YES];
    
    // 发送"登录"指令
    NSString *cookie = [NSString stringWithFormat:@"%f",CFAbsoluteTimeGetCurrent()];
    [cloudroomVideoMgr login:account appSecret:md5Pswd nickName:nickname userID:nickname userAuthCode:@"" cookie:cookie];
    
}

/* 注销 */
- (void)_handleLogout {
    // 注销
    [[CloudroomVideoMgr shareInstance] logout];
}

/* 设置 */
- (void)_handleSettings {
    
}

/* 创建房间 */
- (void)_handleCreateMeeting {
    NSString *userID = [[CRSDKHelper shareInstance] nickname];
    NSString *title = nil;
    if (![NSString stringCheckEmptyOrNil:userID]) {
        title = [NSString stringWithFormat:@"%@的视频房间", userID];
    }
    
//    [HUDUtil hudShowProgress:@"正在创建房间..." animated:YES];
    NSString *cookie = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
    // 发送"创建房间"命令(不设置密码)
    [[CloudroomVideoMgr shareInstance] createMeeting:title createPswd:NO cookie:cookie];
}

/* 进入房间 */
- (void)_handleEnterMeeting {
    NSString *inputText = _meetingID;
    
    MeetInfo *meetInfo = [[MeetInfo alloc] init];
    [meetInfo setID:[inputText intValue]];
    
    [self _jumpToMeetingWithMeetInfo:meetInfo];
}

/**
 跳转到"房间"界面
 @param meetInfo 房间信息
 */
- (void)_jumpToMeetingWithMeetInfo:(MeetInfo *)meetInfo {
    _meetingWindowController = nil;
    MeetingWindowController *meetingWindowController = self.meetingWindowController;
    meetingWindowController.meetInfo = meetInfo;
    [meetingWindowController.window center];
    [meetingWindowController.window orderFront:nil];
    
    [self.window orderOut:nil];
    
    [self setButonEnable:YES];
}

/* 四位随机数生成 参考: [iOS 随机数生成][https://www.jianshu.com/p/f3f26608d1dd] */
- (NSInteger)_randomNumFrom:(NSInteger)from to:(NSInteger)to {
    return (from + (NSInteger)(arc4random() % (to - from + 1)));
}

#pragma mark - CloudroomVideoMgrCallBack>

// 登录成功
- (void)loginSuccess:(NSString *)usrID cookie:(NSString *)cookie {
//    [HUDUtil hudHiddenProgress:YES];
    
    if (_createMeeting) {
        [self _handleCreateMeeting];
    } else {
        [self _handleEnterMeeting];
    }
}

// 登录失败
- (void)loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    
    if (sdkErr == CRVIDEOSDK_NOSERVER_RSP) {
        [NSAlert  alertMessage:@"服务器无响应"];
    }
    else if (sdkErr == CRVIDEOSDK_LOGINSTATE_ERROR) {
        [NSAlert  alertMessage:@"登陆状态不对"];
        [[CloudroomVideoMgr shareInstance] logout];
    }
    else if (sdkErr == CRVIDEOSDK_SOCKETTIMEOUT) {
        [NSAlert  alertMessage:@"网络超时"];
    }
    else if (sdkErr == CRVIDEOSDK_ANCTPSWD_ERR) {
        [NSAlert  alertMessage:@"账号密码不正确"];
    }
    else if (sdkErr == CRVIDEOSDK_RSPDAT_ERR) {
        [NSAlert  alertMessage:@"响应数据不正确"];
    }
    else {
        [NSAlert  alertMessage:[NSString stringWithFormat:@"登录失败(%d)", sdkErr]];
    }
    
    [self setButonEnable:YES];
}

// 创建房间成功回调
- (void)createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie {
    [self _jumpToMeetingWithMeetInfo:meetInfo];
}

// 创建房间失败回调
- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    [NSAlert  alertMessage:@"创建失败"];
    [self setButonEnable:YES];
}

- (MeetingWindowController *)meetingWindowController {
    if (!_meetingWindowController) {
        _meetingWindowController = [[MeetingWindowController alloc] initWithWindowNibName:@"MeetingWindowController"];
    }
    return _meetingWindowController;
}

@end
