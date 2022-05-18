//
//  ConfigViewController.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/11.
//

#import "ConfigViewController.h"
#import "CRSDKHelper.h"
#import "AppDelegate.h"

@interface ConfigViewController () <NSWindowDelegate>
@property (weak) IBOutlet NSTextField *serverTF;
@property (weak) IBOutlet NSTextField *appIDTF;
@property (weak) IBOutlet NSSecureTextField *secretTF;
@property (weak) IBOutlet NSButton *httpButton;
@property (weak) IBOutlet NSButton *httpsButton;
@end

@implementation ConfigViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    if ([NSString stringCheckEmptyOrNil:meetingHelper.account] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.pswd] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.server] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.datEncType]) {
        [self _handleReset];
    } else {
        _serverTF.stringValue = meetingHelper.server;
        _appIDTF.stringValue = meetingHelper.account;
        _secretTF.stringValue = meetingHelper.pswd;
    }
    
    int datEncTypeInt = meetingHelper.datEncType.intValue;
    if (datEncTypeInt >= 1) {
        self.httpButton.state = NSControlStateValueOff;
        self.httpsButton.state = NSControlStateValueOn;
    } else {
        self.httpButton.state = NSControlStateValueOn;
        self.httpsButton.state = NSControlStateValueOff;
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    self.view.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [[appDelegate.mainWindow window] makeKeyAndOrderFront:nil];
}

- (void)_handleSave {
    NSString *server = [_serverTF.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *account = _appIDTF.stringValue;
    NSString *pswd = _secretTF.stringValue;
    NSString* rsaPublicKey = @"rsaPublicKey";

    
    if ([NSString stringCheckEmptyOrNil:server]) {
        [NSAlert  alertMessage:@"服务器地址不能为空!"];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:account]) {
        [NSAlert  alertMessage:@"用户名不能为空!"];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:pswd]) {
        [NSAlert  alertMessage:@"密码不能为空!"];
        return;
    }
    
    NSString *datEncType = @"0";
    if (self.httpsButton.state == NSControlStateValueOn) {
        datEncType = @"1";
    }
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper writeAccount:account pswd:pswd server:server datEncType:datEncType];
    
    [[CloudroomVideoMgr shareInstance] logout];
    [AppDelegate _setupForVideoCallSDK];
}

- (void)_handleReset {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper resetInfo];
    
    _serverTF.stringValue = meetingHelper.server;
    _appIDTF.stringValue = meetingHelper.account;
    _secretTF.stringValue = meetingHelper.pswd;
}

- (IBAction)restoreConfigAction:(id)sender {
    [self _handleReset];
    [self _handleSave];
}

- (IBAction)saveAction:(id)sender {
    [self _handleSave];
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [[appDelegate.mainWindow window] makeKeyAndOrderFront:nil];
    [self.view.window orderOut:nil];
}

- (IBAction)http:(id)sender {
    self.httpsButton.state = NSControlStateValueOff;
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
}

- (IBAction)https:(id)sender {
    self.httpButton.state = NSControlStateValueOff;
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
}

@end
