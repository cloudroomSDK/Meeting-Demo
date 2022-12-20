//
//  MeetingController.m
//  Meeting
//
//  Created by king on 2017/11/14.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "MeetingController.h"

#import "MContentView.h"
#import "MBottomView.h"
#import "MTopView.h"
#import "MFrameView.h"
#import "MRatioView.h"
#import "MChatView.h"

#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "SDKUtil.h"
#import "IQKeyboardManager.h"
#import "MChatModel.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MeetingController () <CloudroomVideoMeetingCallBack, CloudroomVideoMgrCallBack, BKBrushViewDelegate>

@property (nonatomic, weak) IBOutlet MContentView *contentView; /**< 分屏 */
@property (nonatomic, weak) IBOutlet MBottomView *bottomView; /**< 操作 */
@property (nonatomic, weak) IBOutlet MFrameView *frameView; /**< 帧率视*/
@property (nonatomic, weak) IBOutlet MRatioView *ratioView; /**< 分辨率 */
@property (nonatomic, weak) IBOutlet CLShareView *shareView; /**< 屏幕共享 */
@property (nonatomic, strong) MChatView *chatView; /**< IM */

@property (nonatomic, strong) NSMutableArray<UsrVideoId *> *members; /**< 房间成员 */
@property (nonatomic, copy) NSArray<NSString *> *ratioArr; /**< 分辨率集合 */
@property (nonatomic, copy) NSArray<UsrVideoInfo *> *cameraArray; /**< 摄像头集合 */
@property (nonatomic, strong) NSMutableArray<MChatModel *> *messages;
@property (nonatomic, assign) NSInteger curCameraIndex; /**< 当前摄像头索引 */
@property (nonatomic, strong) UIAlertController *dropVC; /**< 掉线弹框 */
@property (nonatomic, assign) BOOL enableMark; /**< 标注? */
@property (weak, nonatomic) IBOutlet CLMediaView *mediaView;
@property (nonatomic, assign) int devID;
@end


@implementation MeetingController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _commonSetup];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    // 不灭屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // 更新代理
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr setMgrCallback:self];
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting setMeetingCallBack:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr removeMgrCallback:self];
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting removeMeetingCallBack:self];
}

#pragma mark - VideoMgrDelegate
// 掉线通知
- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr {
    if (_dropVC) {
        [_dropVC dismissViewControllerAnimated:NO completion:^{
            _dropVC = nil;
            
            if (sdkErr == CRVIDEOSDK_KICKOUT_BY_RELOGIN) { // 被踢
                [self _showAlert:@"您的帐号在别处被使用!"];
            } else { // 掉线
                [self _showAlert:@"您已掉线!"];
            }
        }];
        return;
    }
    
    if (sdkErr == CRVIDEOSDK_KICKOUT_BY_RELOGIN) { // 被踢
        [self _showAlert:@"您的帐号在别处被使用!"];
    } else { // 掉线
        [self _showAlert:@"您已掉线!"];
    }
}

#pragma mark - VideoMeetingDelegate
// 入会结果
- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code {
    [HUDUtil hudHiddenProgress:YES];
    
    if (code == CRVIDEOSDK_NOERR) {
        [self _enterMeetingSuccess];
    } else if (code == CRVIDEOSDK_MEETROOMLOCKED) {// FIXME:房间加锁后,进入房间提示语不正确 added by king 201711291513
        [self _enterMeetingFail:@"房间已加锁!"];
    } else {
        [self _enterMeetingFail:@"进入房间失败!"];
    }
}

- (void)userEnterMeeting:(NSString *)userID {
    NSString *text = [NSString stringWithFormat:@"%@进入房间!", userID];
    [HUDUtil hudShow:text delay:3 animated:YES];
    
    for (MemberInfo *member in [[CloudroomVideoMeeting shareInstance] getAllMembers]) {
        MLog(@"userId:%@ nickName:%@", member.userId, member.nickName);
    }
    
    [self _updateVideoInfo];
}

- (void)userLeftMeeting:(NSString *)userID {
    NSString *text = [NSString stringWithFormat:@"%@离开房间!", userID];
    [HUDUtil hudShow:text delay:3 animated:YES];
    
    [self _updateVideoInfo];
}

// 房间被结束
- (void)meetingStopped{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:@"房间已结束!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _jumpToPMeeting];
    }];
    [alertController addAction:doneAction];
    if(@available(iOS 13.0, *)) {
        
        alertController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:alertController animated:YES completion:^{}];
}

// 房间掉线
- (void)meetingDropped:(CRVIDEOSDK_MEETING_DROPPED_REASON)reason{
    [self _showReEnter:@"房间掉线!"];
}

// 本地音频设备有变化
- (void)audioDevChanged{
    [self _updateMic];
}

// 音频设备状态变化
- (void)audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus {
    [self _updateMic];
}

// 视频设备状态变化
- (void)videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus {
    [self _setCamera];
    [self _updateCamera];
    
    // 订阅摄像头
    [self _updateVideoInfo];
}

// 本地视频设备有变化
- (void)videoDevChanged:(NSString *)userID {
    [self _setCamera];
    [self _updateCamera];
    
    // 订阅摄像头
    [self _updateVideoInfo];
}

// 屏幕共享操作通知
- (void)notifyScreenShareStarted{
    [HUDUtil hudShow:@"屏幕共享已开始" delay:3 animated:YES];
    
    _contentView.shareStyle = YES;
    [self.shareView setHidden:NO];
}

- (void)notifyScreenShareStopped{
    [HUDUtil hudShow:@"屏幕共享已结束" delay:3 animated:YES];
    
    [self.shareView setHidden:YES];
    _contentView.shareStyle = NO;
    [self _updateVideoInfo];
}

// 屏幕共享数据更新,用户收到该回调消息后应该调用getShareScreenDecodeImg获取最新的共享数据
- (void)notifyScreenShareData:(NSString *)userID changedRect:(CGRect)changedRect frameSize:(CGSize)size {

}

// 视频墙分屏模式回调(0:互看 1:1分屏 2:2分屏 3:4分屏 4:5分屏 5:6分屏 6:9分屏 7:13分屏 8:16分屏)
- (void)notifyVideoWallMode:(int)wallMode {
}

// IM 消息发送结果
-(void)sendCustomMeetingMsgRslt:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    if (sdkErr != CRVIDEOSDK_NOERR) {
        [HUDUtil hudShow:@"消息发送失败" delay:3 animated:YES];
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
    
    if (![_chatView isShow]) {
        [_chatView showAnimation];
    }
    
    MChatModel *chatModel = [[MChatModel alloc] initWithName:fromUserID content:dic[@"IMMsg"]];
    [self.messages addObject:chatModel];
    _chatView.message = [self.messages copy];
}



// 屏幕共享标注开始回调
- (void)notifyScreenMarkStarted {

}

// 屏幕共享标注停止回调
- (void)notifyScreenMarkStopped{
}

// 屏幕共享是否允许他人标注回调
- (void)enableOtherMark:(BOOL)enable {
    
}

// 屏幕共享标注回调
- (void)sendMarkData:(MarkData *)markData {
   
}

// 屏幕共享所有标注回调
- (void)sendAllMarkData:(NSArray<MarkData *> *)markDatas {

}

// 清除所有屏幕共享标注回调
- (void)clearAllMarks{

    
}


- (void)setNickNameRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userid:(NSString*)userid newName:(NSString*)newName
{
}

- (void)notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName
{
    [_contentView updateUIViews:self.members localer:@""];
}


#pragma mark - private method
- (void)_commonSetup {
    // 设置属性
    [self _setupProperty];
    // 入会操作
    [self _enterMeeting];
    
    [self.shareView setHidden:YES];
    
    self.shareView.isSharer = NO;
    
    [self.view bringSubviewToFront:self.shareView];
}

/**
 设置属性
 */
- (void)_setupProperty {
    /* 聊天 */
    MChatView *chatView = [[MChatView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:chatView];
    [self.view insertSubview:chatView belowSubview:_bottomView];
    _chatView = chatView;
    [_chatView setTextFieldShouldReturn:^(MChatView *chatView, NSString *text) {
        NSLog(@"send message:%@", text);
        // 发送 IM 消息
        CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        NSString *cookie = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];

        
        NSString*data = [NSString stringWithFormat:@"{\"CmdType\":\"IM\",\"IMMsg\":\"%@\"}",text];

        [cloudroomVideoMeeting sendMeetingCustomMsg:data cookie:cookie];

    }];
    [_chatView setTitle:[NSString stringWithFormat:@"房间号:%d", _meetInfo.ID]];
    
    _curCameraIndex = 0;
    
    weakify(self)
    [_bottomView setResponse:^(MBottomView *view, UIButton *sender) {
        strongify(wSelf)
        
        switch ([sender tag]) {
            case MBottomViewBtnTypeMic: {
                [sSelf _handleMic:sender];
                break;
            }
            case MBottomViewBtnTypeCamera: {
                [sSelf _handleCamera:sender];
                break;
            }
            case MBottomViewBtnTypeChat: {
                
                [sSelf _handleChat];
                break;
            }
            case MBottomViewBtnTypeExCamera: {
                [sSelf _handleExCamera];
                break;
            }
            case MBottomViewBtnTypeRatio: {
                [sSelf _handleRatio];
                break;
            }
            case MBottomViewBtnTypeExit: {
                [sSelf _handleExit];
                break;
            }
            case MBottomViewBtnTypeFrame: {
                [wSelf _handleFrame];
                break;
            }
        }
    }];
    
    /* 分辨率 */
    _ratioView.dataSource = @[@"360*360", @"480*480", @"720*720"];
    [_ratioView setResponse:^(MRatioView *view, UIButton *sender, NSString *value) {
        switch ([sender tag]) {
            case MRatioViewBtnTypeCancel: break;
            case MRatioViewBtnTypeDone: [SDKUtil setRatio:[SDKUtil getRatioFromString:value]]; break;
        }
    }];
    
    /* 帧率 */
    _frameView.dataSource = @[@"10", @"15", @"24"];
    [_frameView setResponse:^(MFrameView *view, UIButton *sender, NSString *value) {
        switch ([sender tag]) {
            case MFrameViewBtnTypeCancel: break;
            case MFrameViewBtnTypeDone: [SDKUtil setFps:[value intValue]]; break;
        }
    }];
    
}

- (void)_setStatusBarBG {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.5);
    }
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



/* 入会操作 */
- (void)_enterMeeting {
    if (_meetInfo.ID > 0) {
        [HUDUtil hudShowProgress:@"正在进入房间..." animated:YES];
        CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        NSString *nickname = [[CRSDKHelper shareInstance] nickname];
        [cloudroomVideoMeeting enterMeeting:_meetInfo.ID pswd:@"" userID:nickname nikeName:nickname];
    }
}

/* 入会成功 */
- (void)_enterMeetingSuccess {
    // 打开本地麦克风
    [SDKUtil openLocalMic];
    // 打开本地摄像头
    [SDKUtil openLocalCamera];
    
    [self _updateMic];
    
    [self _setupForCamera];
    
    // 订阅摄像头
    [self _setCamera];
    [self _updateCamera];
    [self _updateVideoInfo];
    
    // 设置默认分辨率: 360*360
    [SDKUtil setRatio:CGSizeMake(360, 360)];
    // 设置默认帧率: 15
    [SDKUtil setFps:15];
    // 设置默认优先级: 画质优先
    [SDKUtil setPriority:25 min:22];
    
    [[CloudroomVideoMeeting shareInstance] setSpeakerOut:YES];
}

/**
 入会失败
 @param message 失败信息
 */
- (void)_enterMeetingFail:(NSString *)message {
    [HUDUtil hudShow:message delay:3 animated:YES];
    
    if (_meetInfo.ID > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self _jumpToPMeeting];
        }];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self _enterMeeting];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:doneAction];
        if(@available(iOS 13.0, *)) {
             
             alertController.modalPresentationStyle = UIModalPresentationFullScreen;
         }
        [self presentViewController:alertController animated:NO completion:nil];
    }
}

/**
 重登操作
 @param message 重登信息
 */
- (void)_showReEnter:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"离开房间" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self _jumpToPMeeting];
        _dropVC = nil;
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 离开房间
        [[CloudroomVideoMeeting shareInstance] exitMeeting];
        // 重新入会
        [self _enterMeeting];
        _dropVC = nil;
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    if(@available(iOS 13.0, *)) {
         
         alertController.modalPresentationStyle = UIModalPresentationFullScreen;
     }
    [self presentViewController:alertController animated:NO completion:^{}];
    _dropVC = alertController;
}

/* 掉线/被踢下线 */
- (void)_showAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _jumpToPMeeting];
    }];
    [alertController addAction:doneAction];
    if(@available(iOS 13.0, *)) {
         
         alertController.modalPresentationStyle = UIModalPresentationFullScreen;
     }
    [self presentViewController:alertController animated:YES completion:^{}];
}


/* 更新摄像头开关 UI */
- (void)_updateCamera {
    VIDEO_STATUS status = [SDKUtil getLocalCameraStatus];
    [_bottomView updateCamera:!(status == AOPEN || status == AOPENING)];
}

/* 更新麦克风开关 UI */
- (void)_updateMic {
    AUDIO_STATUS status = [SDKUtil getLocalMicStatus];
    [_bottomView updateMic:!(status == VOPEN || status == VOPENING)];
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
    
    [_contentView updateUIViews:self.members localer:myUserID];
}

// TODO: 按钮响应事件
/* 开/关麦克风 */
- (void)_handleMic:(UIButton *)sender {
    if (sender.selected) {
        [SDKUtil closeLocalMic];
        
    } else {
        [SDKUtil openLocalMic];
    }
}

- (void)_handleChat {
   [_chatView clickShow];
    
    //多流设置测试
//    NSMutableArray <UsrVideoId *> * video =  [[CloudroomVideoMeeting shareInstance] getWatchableVideos];
//    int videoID   = video.firstObject.videoID;
//    VideoCfg *cfg1 = [[VideoCfg alloc]init];
//    cfg1.sizeType  = VSIZE_SZ_720;
//    cfg1.fps = 12;
//    cfg1.maxbps = 1000000;
//    cfg1.whRate = WHRATE_1_1;
//
//
//    VideoCfg *cfg2 = [[VideoCfg alloc]init];
//    cfg2.sizeType  = VSIZE_SZ_128;
//    cfg2.fps = 12;
//    cfg2.maxbps = 1000000;
//    cfg2.whRate = WHRATE_1_1;
//
//    CamAttribute *attr = [[CamAttribute alloc]init];
//    attr.disabled = false;
//    attr.quality1_cfg = cfg1;
//    attr.quality2_cfg = cfg2;
//    [[CloudroomVideoMeeting shareInstance] setLocVideoAttributes:videoID attributes:attr];
//    NSString *locationInfo = [NSString stringWithFormat:@"{\"subject\": %@}",@"ceshihuiyi"];
    
}


/* 开/关摄像头 */
- (void)_handleCamera:(UIButton *)sender {
    if (sender.selected) {
        [SDKUtil closeLocalCamera];
    } else {
        [SDKUtil openLocalCamera];
    }
}

-(void)modifyUserName:(NSString*)name
{
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *userID = [cloudroomVideoMeeting getMyUserID];
    [cloudroomVideoMeeting setNickName:userID nickName:name];
}

-(void)setupMicMute
{
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting setSpeakerMute:true];
}

/* 切换摄像头 */
- (void)_handleExCamera {
    
   // [[CloudroomVideoMeeting shareInstance] setSpeakerMute:true];
    
    
    // FIXME: 切换摄像头之前,先检测是否关闭 (king 20180717)
    if (![SDKUtil isLocalCameraOpen]) {
        [HUDUtil hudShow:@"摄像头已关闭" delay:3 animated:YES];
        return;
    }
    
    if ([_cameraArray count] <= 1) {
        MLog(@"无法切换摄像头!");
        return;
    }
    
    if (_curCameraIndex == 0) {
        _curCameraIndex = 1;
    } else {
        _curCameraIndex = 0;
    }
    
    [self _setCamera];
}

/* 分辨率 */
- (void)_handleRatio {
    _ratioView.curRatio = [SDKUtil getStringFromRatio];
    [_ratioView showAnimation];
}

/* 退出 */
- (void)_handleExit {
    
    // FIXME: 退出房间,防止误操作 (king 20180717)
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"离开房间?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self _jumpToPMeeting];
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:done];
    if(@available(iOS 13.0, *)) {
         
         alertVC.modalPresentationStyle = UIModalPresentationFullScreen;
     }
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)_handleFrame {
    _frameView.curFrame = [SDKUtil getStringFromFrame];
    [_frameView showAnimation];
}

/* 跳转到"预入会"界面 */
- (void)_jumpToPMeeting {
    // 离开房间
    [[CloudroomVideoMeeting shareInstance] exitMeeting];
    // 注销
    [[CloudroomVideoMgr shareInstance] logout];
    
    // 退出界面
    [self dismissViewControllerAnimated:NO completion:nil];
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

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    if (![touch.view isEqual:_bottomView]) {
        if (_chatView.isShow) {
            [_chatView hideAnimation];
        } else {
            [_chatView showAnimation];
        }
    }
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// TODO: 测试白板功能 (king 20180716)
- (void)_boardTest {
    
}

//-(void)customCam{
//    
//    // 创建NSTimer对象
//    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//    // 加入RunLoop中
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    
//}
//
//- (void)timerAction:(NSTimer *)sender {
// 
//    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
//    
//    NSData *data = [self _imageWithView:self.view];
//    [cloudroomVideoMeeting inputCustomVideoDat:_devID data:data timeStamp:2];
//}
//
//- (NSData *)_imageWithView:(UIView *)view
//{
//    CGSize size = view.bounds.size;
//    UIGraphicsBeginImageContextWithOptions(size, NO, 2.88);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
//    [view.layer renderInContext:context];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGImageRef imageRef = image.CGImage;
//    NSUInteger imageW = CGImageGetWidth(imageRef);
//    NSUInteger imageH = CGImageGetHeight(imageRef);
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * imageW;
//    NSUInteger bitsPerComponent = 8;
//    size_t imageBytes = imageW * imageH * bytesPerPixel;
//    unsigned char *imageBuf = malloc(imageBytes);
//    
//    NSLog(@"width:%lu height:%ld",(unsigned long)imageW,imageH);
//
//    {
//        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//
//        CGContextRef context = CGBitmapContextCreate(imageBuf,
//                                                     imageW,
//                                                     imageH,
//                                                     bitsPerComponent,
//                                                     bytesPerRow,
//                                                     space,
//                                                     kCGImageAlphaPremultipliedLast); // RGBA
//
//        CGRect rect = CGRectMake(0, 0, imageW, imageH);
//        CGContextDrawImage(context, rect, imageRef);
//        CGColorSpaceRelease(space);
//        CGContextRelease(context);
//    }
//    //NSLog(@"data size:%zu", imageBytes);
//    NSData* data = [NSData dataWithBytes:imageBuf length:imageBytes];
//    free(imageBuf);
//    return data;
////    return UIImagePNGRepresentation(image);
//}
//
//-(BOOL)saveImage:(UIImage*)image ToDocmentWithFileName:(NSString*)fileName{
//    
//    //2.保存到对应的沙盒目录中，具体代码如下：
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
//    // 保存文件的名称 CGSize size = CGSizeMake(320, 480);
//    //图片大小 UIImage* img = [Util scaleToSize:image size:size];//调用图片大小截取方法
//    BOOL result = [UIImagePNGRepresentation(image) writeToFile: filePath atomically:YES];
//    // 保存成功会返回YES
//    if (result) { return YES; }else{ return NO; }
//    
//}
 
-(void)notifyMediaStart:(NSString *)userid
{
    _contentView.shareStyle = YES;
    [self.mediaView clearFrame];
    [self.mediaView setHidden:NO];
    [self.contentView setHidden:YES];
}

- (void)notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason
{
    [self.mediaView clearFrame];
    [self.mediaView setHidden:YES];
    [self.contentView setHidden:NO];
    _contentView.shareStyle = NO;
    [self _updateVideoInfo];
}


@end
