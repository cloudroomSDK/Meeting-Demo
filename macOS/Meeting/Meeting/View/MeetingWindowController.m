//
//  MeetingWindowController.m
//  Meeting(OC)
//
//  Created by YunWu01 on 2021/11/5.
//

#import "MeetingWindowController.h"
#import "CRSDKHelper.h"
#import "SDKUtil.h"
#import "VideoWallView.h"
#import "MemberViewController.h"
#import "MessageViewController.h"
#import "MeetingCfgWindowController.h"
#import "AppDelegate.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "InputMediaUrlWindowController.h"
#import "RecordConfigWindowController.h"

@interface MeetingWindowController () <CloudroomVideoMeetingCallBack, CloudroomVideoMgrCallBack, NSWindowDelegate>
@property (weak) IBOutlet NSView *chatContainerView;
@property (weak) IBOutlet NSView *memberContainerView;
@property (weak) IBOutlet CLMediaView *mediaVew;
@property (weak) IBOutlet CLShareView *screenShareView;
@property (weak) IBOutlet VideoWallView *videoWallView;
@property (weak) IBOutlet NSView *twoView;
@property (weak) IBOutlet NSView *fourView;
@property (weak) IBOutlet NSView *nineView;


@property (nonatomic, strong) NSMutableArray<MChatModel *> *messages;
@property (nonatomic, strong) NSMutableArray<UsrVideoId *> *members; /**< 房间成员 */
@property (nonatomic, copy) NSArray<NSString *> *ratioArr; /**< 分辨率集合 */
@property (nonatomic, copy) NSArray<UsrVideoInfo *> *cameraArray; /**< 摄像头集合 */
@property (nonatomic, assign) NSInteger curCameraIndex; /**< 当前摄像头索引 */
@property (nonatomic, assign) BOOL enableMark; /**< 标注? */
@property (weak, nonatomic) IBOutlet CLMediaView *mediaView;
@property (nonatomic, assign) int devID;

@property (nonatomic, strong) MemberViewController *memberController;
@property (nonatomic, strong) NSMutableArray<MemberInfo *> *memberList;
@property (nonatomic, strong) MessageViewController *chatController;
@property (nonatomic, strong) MeetingCfgWindowController *cfgWindowController;
@property (weak) IBOutlet NSPopUpButton *wallModePopUpButton;
@property (weak) IBOutlet NSButton *screenShareButton;
@property (weak) IBOutlet NSButton *networkMediaButton;
@property (weak) IBOutlet NSButton *localMediaButton;
@property (nonatomic, strong) InputMediaUrlWindowController *inputMediaUrlWindow;
@property (weak) IBOutlet NSButton *recordButton;
@property (nonatomic, strong) RecordConfigWindowController *recordWindow;
@property (weak) IBOutlet NSSlider *mediaVolumSlider;
@property (weak) IBOutlet NSButton *mediaPauseButton;
@property (nonatomic, assign) REC_CONTENT_TYPE recType;
@end

@implementation MeetingWindowController

- (void)dealloc {
    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
//    self.window.delegate = self;
    
    // 更新代理
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr addMgrCallback:self];
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting addMeetingCallback:self];
    
    [self _commonSetup];
    [self preventSystemSleep];
}

- (void)windowWillClose:(NSNotification *)notification {
    // 离开房间
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting removeMeetingCallBack:self];
    [cloudroomVideoMeeting exitMeeting];
    
    // 注销
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr removeMgrCallback:self];
    [[CloudroomVideoMgr shareInstance] logout];
    
    [self.cfgWindowController close];
    
    [((AppDelegate *)[[NSApplication sharedApplication] delegate]).mainWindow showWindow:self];
}

#pragma mark - VideoMeetingDelegate

- (void)meetingStopped {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.messageText = @"会议已被结束";
    [alert addButtonWithTitle:@"确定"];
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self close];
    }
}

- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    
    switch (sdkErr) {
        case CRVIDEOSDK_KICKOUT_BY_RELOGIN:
            alert.messageText = @"您的帐号在别处被使用!";
            break;
            
        default:
            alert.messageText = @"您已掉线!";
            break;
    }
    
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self close];
    }
}

/**
 会议掉线回调
 */
- (void)meetingDropped:(CRVIDEOSDK_MEETING_DROPPED_REASON)reason {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    
    switch (reason) {
        case CRVIDEOSDK_DROPPED_KICKOUT:
            alert.messageText = @"您已被请出会议";
            break;
            
        case CRVIDEOSDK_DROPPED_BALANCELESS:
            alert.messageText = @"余额不足";
            break;
        default:
            break;
    }
    
    
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self close];
    }
}

// 入会结果
- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code {
    
    if (code == CRVIDEOSDK_NOERR) {
        [self _enterMeetingSuccess];
    } else if (code == CRVIDEOSDK_MEETROOMLOCKED) {// FIXME:房间加锁后,进入房间提示语不正确 added by king 201711291513
        [NSAlert  alertMessage:@"房间已加锁!"];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleInformational;
        alert.messageText = [NSString stringWithFormat:@"进入房间失败!(%d)", code];
        [alert addButtonWithTitle:@"确定"];
        
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [self close];
        }
    }
}

- (void)userEnterMeeting:(NSString *)userID {
    NSString *text = [NSString stringWithFormat:@"%@进入房间!", userID];
//    [HUDUtil hudShow:text delay:3 animated:YES];
    
    __block NSInteger index = -1;
    MemberInfo *enterMember = [[CloudroomVideoMeeting shareInstance] getMemberInfo:userID];
    [self.memberList enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([enterMember.userId isEqualToString:obj.userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        [self.memberList replaceObjectAtIndex:index withObject:enterMember];
    } else {
        [self.memberList addObject:enterMember];
    }
    [self.memberController reloadTableView];
    
    [self _updateVideoInfo];
}

- (void)userLeftMeeting:(NSString *)userID {
    NSString *text = [NSString stringWithFormat:@"%@离开房间!", userID];
//    [HUDUtil hudShow:text delay:3 animated:YES];
    
    NSMutableArray *kItemMuArr = [NSMutableArray array];
    [self.memberList enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([userID isEqualToString:obj.userId]) {
            [kItemMuArr addObject:obj];
            *stop = YES;
        }
    }];
    [self.memberList removeObjectsInArray:kItemMuArr];
    [self.memberController reloadTableView];
    
    [self _updateVideoInfo];
}

- (void)notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName {
    [self.memberList enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([userid isEqualToString:obj.userId]) {
            obj.nickName = newName;
            *stop = YES;
        }
    }];
    [self.memberController reloadTableView];
    
    [self _updateVideoInfo];
}

// 本地音频设备有变化
- (void)audioDevChanged{
    NSString *myUserID = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    NSArray<MemberInfo *> *members = [self.memberList copy];
    [members enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:myUserID]) {
            obj.audioStatus = [[CloudroomVideoMeeting shareInstance] getAudioStatus:myUserID];
            *stop = YES;
        }
    }];
    [self.memberController reloadTableView];
}

// 音频设备状态变化
- (void)audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus {
    NSArray<MemberInfo *> *members = [self.memberList copy];
    [members enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userID]) {
            obj.audioStatus = newStatus;
            *stop = YES;
        }
    }];
    [self.memberController reloadTableView];
}

// 视频设备状态变化
- (void)videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus {
//    [self _updateCamera];
    
    // 订阅摄像头
    [self _updateVideoInfo];
    
    NSArray<MemberInfo *> *members = [self.memberList copy];
    [members enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userID]) {
            obj.videoStatus = newStatus;
            *stop = YES;
        }
    }];
    [self.memberController reloadTableView];
}

// 本地视频设备有变化
- (void)videoDevChanged:(NSString *)userID {
//    [self _setupForCamera];
    
    // 订阅摄像头
    [self _updateVideoInfo];
    
    NSString *myUserID = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    NSArray<MemberInfo *> *members = [self.memberList copy];
    [members enumerateObjectsUsingBlock:^(MemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:myUserID]) {
            obj.videoStatus = [[CloudroomVideoMeeting shareInstance] getVideoStatus:myUserID];
            *stop = YES;
        }
    }];
    [self.memberController reloadTableView];
}

- (void)notifyVideoWallMode:(int)wallMode {
    if (!self.screenShareView.isHidden) [self.screenShareView setHidden:YES];
    if (!self.mediaView.isHidden) [self.mediaView setHidden:YES];
    if (self.videoWallView.isHidden) [self.mediaView setHidden:NO];
    
    if (wallMode == MContentViewType_2 || wallMode == MContentViewType_4 || wallMode == MContentViewType_6) {
        [self.videoWallView setType:(MContentViewType)wallMode];
        
        NSInteger index = 0;
        switch (wallMode) {
            case 2:
                index = 0;
                break;
                
            case 4:
                index = 1;
                break;
                
            case 6:
                index = 2;
                break;
                
            default:
                break;
        }
        [self.wallModePopUpButton selectItemAtIndex:index];
        [self _updateVideoInfo];
        
        // 更新录制内容
        _recordWindow.videoType = wallMode;
        if ([self.recordButton.title isEqualToString:@"结束录制"]) {
            [_recordWindow updateRecContent:RECVTP_VIDEO];
        }
    } else {
        [NSAlert alertMessage:@"仅同步2、4、6分屏"];
    }
    
}

#pragma mark - 屏幕共享回调

// 屏幕共享操作通知
- (void)notifyScreenShareStarted{
//    [HUDUtil hudShow:@"屏幕共享已开始" delay:3 animated:YES];
    
    [self.screenShareView setHidden:NO];
    [self.mediaView setHidden:YES];
    [self.videoWallView setHidden:YES];
}

- (void)notifyScreenShareStopped{
//    [HUDUtil hudShow:@"屏幕共享已结束" delay:3 animated:YES];
    
    [self.screenShareView clearFrame];
    [self.screenShareView setHidden:YES];
    [self.videoWallView setHidden:NO];
}

-(void)startScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr
{
    if(sdkErr == CRVIDEOSDK_NOERR) {
        self.recType = RECVTP_SCREEN;
        [self.screenShareButton setTitle:@"停止共享"];
    } else {
        NSLog(@"屏幕共享开启失败");
        [self.screenShareButton setTitle:@"共享屏幕"];
    }
}


-(void)stopScreenShareRslt:(CRVIDEOSDK_ERR_DEF)sdkErr
{
    if(sdkErr == CRVIDEOSDK_NOERR) {
        self.recType = RECVTP_VIDEO;
        [self.screenShareButton setTitle:@"共享屏幕"];
    } else {
        NSLog(@"屏幕共享停止失败");
        [self.screenShareButton setTitle:@"停止共享"];
    }
}

// 屏幕共享数据更新,用户收到该回调消息后应该调用getShareScreenDecodeImg获取最新的共享数据
- (void)notifyScreenShareData:(NSString *)userID changedRect:(CGRect)changedRect frameSize:(CGSize)size {

}

#pragma mark - 影音回调

-(void)notifyMediaStart:(NSString *)userid
{
    self.recType = RECVTP_MEDIA;
    [self.mediaView clearFrame];
    [self.mediaView setHidden:NO];
    [self.screenShareView setHidden:YES];
    [self.videoWallView setHidden:YES];
    
    NSString *myUserId = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    if ([userid isEqualToString:myUserId]) {
        if (_inputMediaUrlWindow) {
            [self.networkMediaButton setTitle:@"停止"];
        } else {
            [self.localMediaButton setTitle:@"停止"];
        }
    }
}

- (void)notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason
{
    [self.mediaView clearFrame];
    [self.mediaView setHidden:YES];
    [self.videoWallView setHidden:NO];
    
    self.mediaPauseButton.hidden = YES;
    self.mediaVolumSlider.hidden = YES;
    
    self.networkMediaButton.title = @"网络影音";
    self.localMediaButton.title = @"本地影音";
    
    self.recType = RECVTP_VIDEO;
}

- (void)notifyMediaPause:(NSString *)userid bPause:(BOOL)bPause {
    
}

- (void)notifyMemberMediaData:(NSString *)userid curPos:(int)curPos {
    
}

/* 更新摄像头开关 UI */
- (void)_updateCamera {
    VIDEO_STATUS status = [SDKUtil getLocalCameraStatus];
//    [_bottomView updateCamera:!(status == AOPEN || status == AOPENING)];
}

/* 更新麦克风开关 UI */
- (void)_updateMic {
    AUDIO_STATUS status = [SDKUtil getLocalMicStatus];
//    [_bottomView updateMic:!(status == VOPEN || status == VOPENING)];
}

/* 更新房间成员 */
- (void)_updateVideoInfo {
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    NSMutableArray <UsrVideoId *> *watchableVideos = [cloudroomVideoMeeting getWatchableVideos];
    
    
    NSMutableArray <UsrVideoId *> *diff = [NSMutableArray array];
    NSMutableArray <UsrVideoId *> *remove = [NSMutableArray array];
    
    // 找到不同元素
    if ([self.members count] <= 0) {
        [diff addObjectsFromArray:watchableVideos];
    }
    else
    {
        for (UsrVideoId *obj1 in watchableVideos)
        {
            BOOL find = NO;
            for (UsrVideoId *obj2 in self.members)
            {
                if ([obj1.userId isEqualToString:obj2.userId] && obj1.videoID == obj2.videoID)
                {
                    find = YES;
                    break;
                }
            }
            
            if (find == NO)
            {
                [diff addObject:obj1];
            }
        }
        
        // 找到删除元素
        for (UsrVideoId *obj1 in self.members)
        {
            BOOL find = NO;
            for (UsrVideoId *obj2 in watchableVideos)
            {
                if ([obj1.userId isEqualToString:obj2.userId] && obj1.videoID == obj2.videoID)
                {
                    find = YES;
                    break;
                }
            }
            
            if (find == NO)
            {
                [remove addObject:obj1];
            }
        }
        
        for (UsrVideoId *usrVideoId in remove) {
            [self.members removeObject:usrVideoId];
        }
    }
    
    [self.members addObjectsFromArray:diff];
    
    [_videoWallView updateUIViews:self.members localer:myUserID];
}

// IM 消息发送结果
-(void)sendCustomMeetingMsgRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    if (sdkErr != CRVIDEOSDK_NOERR) {
//        [HUDUtil hudShow:@"消息发送失败" delay:3 animated:YES];
    } else {
        [self.chatController clearTextField];
    }

}

-(void)notifyCustomMeetingMsg:(NSString *)fromUserID jsonDat:(NSString *)jsonDat
{
    NSLog(@"notifyCustomMeetingMsg:%@",jsonDat);
    if (jsonDat == nil) {
          return ;
      }
    NSData *jsonData = [jsonDat dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return ;
    }
    
    MChatModel *chatModel = [[MChatModel alloc] initWithName:fromUserID content:dic[@"IMMsg"]];
    [self.messages addObject:chatModel];
    [self.chatController reloadTableView];
}

- (void)cloudMixerStateChanged:(NSString *)operatorID mixerID:(NSString *)mixerID state:(MIXER_STATE)state exParam:(NSString *)exParam {
    switch (state) {
        case NO_RECORD: {
            [self.recordButton setTitle:@"录制"];
            break;
        }
        case RECORDING: {
            [self.recordButton setTitle:@"结束录制"];
            break;
        }
        case STARTING:
        case PAUSED:
        case STOPPING: break;
    }
}

#pragma mark - private method
- (void)_commonSetup {
    
    {
        self.twoView.wantsLayer = YES;
        self.fourView.wantsLayer = YES;
        self.nineView.wantsLayer = YES;
        
        self.twoView.layer.backgroundColor = [NSColor systemGrayColor].CGColor;
        self.fourView.layer.backgroundColor = [NSColor systemGrayColor].CGColor;
        self.nineView.layer.backgroundColor = [NSColor systemGrayColor].CGColor;
    }
    
    self.videoWallView.twoView = self.twoView;
    self.videoWallView.fourView = self.fourView;
    self.videoWallView.nineView = self.nineView;
    [self.videoWallView setType:MContentViewType_2];
    
    [self.memberContainerView addSubview:self.memberController.view];
    [self.contentViewController addChildViewController:self.memberController];
    self.memberController.view.frame = self.memberContainerView.bounds;
    self.memberController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.chatContainerView addSubview:self.chatController.view];
    [self.contentViewController addChildViewController:self.chatController];
    self.chatController.view.frame = self.chatContainerView.bounds;
    self.chatController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.chatController setTextFieldShouldReturn:^(NSString * _Nonnull text) {
        if (text.length == 0) {
            return;
        }
        
        NSLog(@"send message:%@", text);
        // 发送 IM 消息
        CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        NSString *cookie = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];

        
        NSString*data = [NSString stringWithFormat:@"{\"CmdType\":\"IM\",\"IMMsg\":\"%@\"}",text];

        [cloudroomVideoMeeting sendMeetingCustomMsg:data cookie:cookie];
    }];
    

    // 设置属性
//    [self _setupProperty];
    // 入会操作
    [self _enterMeeting];
    
}

/* 入会操作 */
- (void)_enterMeeting {
    if (_meetInfo.ID > 0) {
//        [HUDUtil hudShowProgress:@"正在进入房间..." animated:YES];
        CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        [cloudroomVideoMeeting enterMeeting:_meetInfo.ID];
    }
}

/* 入会成功 */
- (void)_enterMeetingSuccess {
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", _meetInfo.ID] forKey:@"KLastEnterMeetingID"];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    // 打开本地麦克风
    [SDKUtil openLocalMic];
    // 打开本地摄像头
    [SDKUtil openLocalCamera];

    [self _setupForCamera];
    
    // 订阅摄像头
    [self _setCamera];
    [self _updateVideoInfo];
    
    // 设置默认分辨率: 360*360
    [SDKUtil setRatio:CGSizeMake(720, 400)];
    // 设置码率
    [SDKUtil setMaxbps:-1];
    // 设置默认帧率: 15
    [SDKUtil setFps:15];
    // 设置默认优先级: 画质优先
    [SDKUtil setPriority:25 min:22];
    
    [[CloudroomVideoMeeting shareInstance] setSpeakerOut:YES];
    
    self.window.title = [NSString stringWithFormat:@"会议号:%d", _meetInfo.ID];
    
    self.memberList = [cloudroomVideoMeeting getAllMembers];
    self.memberController.members = self.memberList;
    [self.memberController reloadTableView];
    
    self.chatController.messages = self.messages;
    [self.chatController reloadTableView];
    
    MIXER_STATE state = [cloudroomVideoMeeting getSvrRecordState];
    if (state == RECORDING) {
        self.recordButton.title = @"结束录制";
    }
    
    int wallMode = [cloudroomVideoMeeting getVideoWallMode];
    if (wallMode == MContentViewType_2 || wallMode == MContentViewType_4 || wallMode == MContentViewType_6) {
        [self notifyVideoWallMode:wallMode];
    }
    
    if (!_recordWindow) _recordWindow = [[RecordConfigWindowController alloc] initWithWindowNibName:@"RecordConfigWindowController"];
    __weak  typeof(self) weakSelf = self;
    [_recordWindow checkLastCloudMixerInfo:^(BOOL cloudMixer) {
        if (cloudMixer) {
            [weakSelf.recordButton setTitle:@"结束录制"];
        }
    }];
}

/**
 初始化摄像头信息
 */
- (void)_setupForCamera {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
     NSMutableArray <UsrVideoInfo *> *videoes = [cloudroomVideoMeeting getAllVideoInfo:myUserID];
    NSArray<UsrVideoInfo *> *cameraArray = [videoes copy];
    if ([cameraArray count] <= 0) {
        MLog(@"获取摄像头设备为空!");
        return;
    }
    
    _cameraArray = cameraArray;
}

/**
 设置摄像头
 */
- (void)_setCamera {
    if ([_cameraArray checkEmptyOrNil]) {
        MLog(@"没有摄像头!");
        return;
    }
    
    if (_curCameraIndex >= [_cameraArray count]) {
        MLog(@"摄像头索引越界!");
        return;
    }
    
    // 设置摄像头设备
    UsrVideoInfo *video = [_cameraArray objectAtIndex:_curCameraIndex];
    [[CloudroomVideoMeeting shareInstance] setDefaultVideo:video.userId videoID:video.videoID];
    MLog(@"当前摄像头为:%zd", _curCameraIndex);
}


#pragma mark - 防止系统休眠
- (void)preventSystemSleep {
    // kIOPMAssertionTypeNoDisplaySleep prevents display sleep,
    // kIOPMAssertionTypeNoIdleSleep prevents idle sleep
    
    // reasonForActivity is a descriptive string used by the system whenever it needs
    // to tell the user why the system is not sleeping. For example,
    // "Mail Compacting Mailboxes" would be a useful string.
    
    //  NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
    CFStringRef reasonForActivity= CFSTR("Describe Activity Type");
    
    IOPMAssertionID assertionID;
    IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                                   kIOPMAssertionLevelOn, reasonForActivity, &assertionID);
    if (success == kIOReturnSuccess)
    {
        //  Add the work you need to do without
        //  the system sleeping here.
        success = IOPMAssertionRelease(assertionID);
        //  The system will be able to sleep again.
    }
}

#pragma mark - Action

- (IBAction)modeAction:(NSPopUpButton *)sender {
    int wallMode = 2;
    switch (sender.indexOfSelectedItem) {
        case 0:
            wallMode = 2;
            break;
            
        case 1:
            wallMode = 4;
            break;
            
        case 2:
            wallMode = 6;
            break;
            
        default:
            break;
    }
    
    [[CloudroomVideoMeeting shareInstance] setVideoWallMode:wallMode];
}

- (IBAction)settingAction:(id)sender {
    if (_cfgWindowController && _cfgWindowController.window.isVisible) {
        [_cfgWindowController.window orderFront:self];
        return;
    }
    
    if (_cfgWindowController) _cfgWindowController = nil;
    [self.configController showWindow:self.window];
}

- (IBAction)startScreenShareAction:(NSButton *)sender {
    
    if (![self canRecordScreen]) {
        [self showScreenRecordingPrompt];
        return;
    }
    
    
    ScreenShareCfg* cfg = [[CloudroomVideoMeeting shareInstance] getScreenShareCfg];
    cfg.maxFPS = 8;
    [[CloudroomVideoMeeting shareInstance] setScreenShareCfg:cfg];
    
    if ([sender.title isEqualToString:@"共享屏幕"]) {
        [[CloudroomVideoMeeting shareInstance] startScreenShare];
        [self.window miniaturize:nil];

    } else if ([sender.title isEqualToString:@"停止共享"]) {
        [[CloudroomVideoMeeting shareInstance] stopScreenShare];
    }
}

- (BOOL)canRecordScreen
{
    if (@available(macOS 10.15, *)) {
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
        NSUInteger numberOfWindows = CFArrayGetCount(windowList);
        NSUInteger numberOfWindowsWithName = 0;
        for (int idx = 0; idx < numberOfWindows; idx++) {
            NSDictionary *windowInfo = (NSDictionary *)CFArrayGetValueAtIndex(windowList, idx);
            NSString *windowName = windowInfo[(id)kCGWindowName];
            if (windowName) {
                numberOfWindowsWithName++;
            } else {
                //no kCGWindowName detected -> not enabled
                break; //breaking early, numberOfWindowsWithName not increased
            }

        }
        CFRelease(windowList);
        return numberOfWindows == numberOfWindowsWithName;
    }
    return YES;
}

- (void)showScreenRecordingPrompt {
  
  /* macos 10.14 and lower do not require screen recording permission to get window titles */
  if(@available(macos 10.15, *)) {
    /*
     To minimize the intrusion just make a 1px image of the upper left corner
     This way there is no real possibilty to access any private data
     */
      CGImageRef c = CGWindowListCreateImage(
                                             CGRectMake(0, 0, 1, 1),
                                             kCGWindowListOptionOnScreenOnly,
                                             kCGNullWindowID,
                                             kCGWindowImageDefault);
  }
}

- (IBAction)startNetworkMediaShareAction:(NSButton *)sender {
    if ([sender.title isEqualToString:@"网络影音"]) {
        if(!_inputMediaUrlWindow.window.isVisible && !_inputMediaUrlWindow) _inputMediaUrlWindow = [[InputMediaUrlWindowController alloc] initWithWindowNibName:@"InputMediaUrlWindowController"];
        [_inputMediaUrlWindow.window center];
        [_inputMediaUrlWindow.window orderFront:self.window];
        
        __weak typeof(self) weakSelf = self;
        [_inputMediaUrlWindow setOpenMediaUrlBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.mediaPauseButton.hidden = NO;
            [strongSelf.mediaPauseButton setTitle:@"暂停"];
            strongSelf.mediaVolumSlider.hidden = NO;
            strongSelf.mediaVolumSlider.intValue = [[CloudroomVideoMeeting shareInstance] getMediaVolume];
        }];
    } else {
        [[CloudroomVideoMeeting shareInstance] stopPlayMedia];
    }
}

- (IBAction)startLocalMediaShareAction:(NSButton *)sender {
    if ([sender.title isEqualToString:@"本地影音"]) {
        _inputMediaUrlWindow = nil;
        
        NSOpenPanel* panel = [NSOpenPanel openPanel];
        //是否可以创建文件夹
        panel.canCreateDirectories = NO;
        //是否可以选择文件夹
        panel.canChooseDirectories = NO;
        //是否可以选择文件
        panel.canChooseFiles = YES;
        
        //是否可以多选
        [panel setAllowsMultipleSelection:NO];
        
        __weak typeof(self) weakSelf = self;
        //显示
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //是否点击open 按钮
            if (result == NSModalResponseOK) {
                //NSURL *pathUrl = [panel URL];
                NSString *pathString = [panel.URLs.firstObject path];
                //停止之前播放
                [[CloudroomVideoMeeting shareInstance] stopPlayMedia];
                [[CloudroomVideoMeeting shareInstance] startPlayMedia:pathString bLocPlay:NO bPauseWhenFinished:NO];
                strongSelf.mediaPauseButton.hidden = NO;
                [strongSelf.mediaPauseButton setTitle:@"暂停"];
                strongSelf.mediaVolumSlider.hidden = NO;
                strongSelf.mediaVolumSlider.intValue = [[CloudroomVideoMeeting shareInstance] getMediaVolume];
            }
            
            
        }];
    } else {
        [[CloudroomVideoMeeting shareInstance] stopPlayMedia];
    }
}

- (IBAction)startRecordAction:(NSButton *)sender {
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    if ([sender.title isEqualToString:@"录制"]) {
        if (!_recordWindow) _recordWindow = [[RecordConfigWindowController alloc] initWithWindowNibName:@"RecordConfigWindowController"];
        _recordWindow.videoType = (VideoWallType)self.videoWallView.type;
        _recordWindow.recordType = _recType;
        [_recordWindow.window center];
        [_recordWindow.window orderFront:self.window];
        __weak typeof(self) weakSelf = self;
        [_recordWindow setStartLocalRecordBlock:^{
            weakSelf.recordButton.title = @"结束录制";
        }];
    } else {
        if (_recordWindow.isSvrRecord) {
            [[CloudroomVideoMeeting shareInstance] destroyCloudMixer:_recordWindow.mixerID];
        } else {
            [cloudroomVideoMeeting destroyLocMixer:@"1"];
            self.recordButton.title = @"录制";
        }
    }
}

- (IBAction)mediaVolumChange:(NSSlider *)sender {
    [[CloudroomVideoMeeting shareInstance] setMediaVolume:sender.intValue];
}

- (IBAction)pauseAction:(NSButton *)sender {
    if ([sender.title isEqualToString:@"暂停"]) {
        [[CloudroomVideoMeeting shareInstance] pausePlayMedia:YES];
        [self.mediaPauseButton setTitle:@"继续"];
    } else if ([sender.title isEqualToString:@"继续"]) {
        [[CloudroomVideoMeeting shareInstance] pausePlayMedia:NO];
        [self.mediaPauseButton setTitle:@"暂停"];
    }
    
    
}


#pragma mark - getter & setter
- (NSMutableArray<UsrVideoId *> *)members {
    if (!_members) {
        _members = [NSMutableArray array];
    }
    
    return _members;
}

- (NSMutableArray<MChatModel *> *)messages {
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    
    return _messages;
}

- (MemberViewController *)memberController {
    if (!_memberController) {
        _memberController = [[MemberViewController alloc] initWithNibName:@"MemberViewController" bundle:nil];
    }
    return _memberController;
}

- (MessageViewController *)chatController {
    if (!_chatController) {
        _chatController = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
    }
    return _chatController;
}

- (MeetingCfgWindowController *)configController {
    if (!_cfgWindowController) {
        _cfgWindowController = [[MeetingCfgWindowController alloc] initWithWindowNibName:@"MeetingCfgWindowController"];
//        _cfgWindowController.cameraArray = _cameraArray;
    }
    return _cfgWindowController;
}

- (void)setRecType:(REC_CONTENT_TYPE)recType {
    if (_recType != recType) {
        if ([self.recordButton.title isEqualToString:@"结束录制"]) {
            [_recordWindow updateRecContent:recType];
        }
    }
    _recType = recType;
}

@end
