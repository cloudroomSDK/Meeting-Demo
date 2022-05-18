//
//  MeetingCfgWindowController.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/18.
//

#import "MeetingCfgWindowController.h"
#import "SDKUtil.h"

@interface MeetingCfgWindowController () <NSWindowDelegate, CloudroomVideoMeetingCallBack>
@property (weak) IBOutlet NSPopUpButton *cameraPopUpButton;
@property (weak) IBOutlet NSPopUpButton *micPopUpButton;
@property (weak) IBOutlet NSPopUpButton *speakerPopUpButton;
@property (weak) IBOutlet NSSlider *speakerSlider;
@property (weak) IBOutlet NSSlider *micphoneSlider;

@property (weak) IBOutlet NSPopUpButton *videoSizePopUpButton;
@property (weak) IBOutlet NSPopUpButton *fpsPopUpButton;


@property (weak) IBOutlet NSButton *picQualityButton;
@property (weak) IBOutlet NSButton *fluencyButton;

@property (weak) IBOutlet NSButton *agcButton;
@property (weak) IBOutlet NSButton *aecButton;
@property (weak) IBOutlet NSButton *ansButton;
@property (nonatomic, assign) NSInteger curCameraIndex; /**< 当前摄像头索引 */
@property (nonatomic, strong) NSMutableArray<ADevInfo *> *spkNames;
@property (nonatomic, strong) NSMutableArray<ADevInfo *> *micNames;
@end

@implementation MeetingCfgWindowController

- (void)dealloc {
    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self  defaultSetting];
    [[CloudroomVideoMeeting shareInstance] addMeetingCallback:self];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[CloudroomVideoMeeting shareInstance] removeMeetingCallBack:self];
}

- (void)audioDevChanged {
    [self reloadAudioPopUpButton];
}

- (void)videoDevChanged:(NSString *)userID {
    [self reloadVideoPopUpButon];
}

- (void)reloadVideoPopUpButon {
    [self.cameraPopUpButton removeAllItems];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    NSMutableArray <UsrVideoInfo *> *videoes = [cloudroomVideoMeeting getAllVideoInfo:myUserID];
    _cameraArray = [videoes copy];
    
    // 设置摄像头列表
    short videoID = [cloudroomVideoMeeting getDefaultVideo:myUserID];
    for (UsrVideoInfo *usrVideoInfo in _cameraArray) {
        [self.cameraPopUpButton addItemWithTitle:usrVideoInfo.videoName];
        if (usrVideoInfo.videoID == videoID) {
            [self.cameraPopUpButton selectItemWithTitle:usrVideoInfo.videoName];
            _curCameraIndex = [self.cameraPopUpButton.itemTitles indexOfObject:usrVideoInfo.videoName];
        }
    }
}

- (void)reloadAudioPopUpButton {
    [self.micPopUpButton removeAllItems];
    [self.speakerPopUpButton removeAllItems];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    
    // 设置麦克风列表
    _micNames = [cloudroomVideoMeeting getAudioMicNames];
    for (ADevInfo *devInfo in _micNames) {
        [self.micPopUpButton addItemWithTitle:devInfo.name];
        if ([devInfo.devId isEqualToString:audioCfg.micDevID]) {
            [self.micPopUpButton selectItemWithTitle:devInfo.name];
        }
    }
    
    // 设置扬声器列表
    _spkNames = [cloudroomVideoMeeting getAudioSpkNames];
    for (ADevInfo *devInfo in _spkNames) {
        [self.speakerPopUpButton addItemWithTitle:devInfo.name];
        if ([devInfo.devId isEqualToString:audioCfg.spkDevID]) {
            [self.speakerPopUpButton selectItemWithTitle:devInfo.name];
        }
    }
}

- (void)defaultSetting {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    NSMutableArray <UsrVideoInfo *> *videoes = [cloudroomVideoMeeting getAllVideoInfo:myUserID];
    _cameraArray = [videoes copy];
    
    // 设置摄像头列表
    [self reloadVideoPopUpButon];
    
    // 设置麦克风、扬声器列表
    [self reloadAudioPopUpButton];
    
    if (audioCfg.agc == 0) {
        self.micphoneSlider.hidden = NO;
        int micVolume = [cloudroomVideoMeeting getMicVolume];
        self.speakerSlider.intValue = micVolume;
    } else {
        self.micphoneSlider.hidden = YES;
    }
    
    // 设置初始音量
    int speakerVolume = [cloudroomVideoMeeting getSpeakerVolume];
    self.speakerSlider.intValue = speakerVolume;
    
    // 视频尺寸
    NSString *videoSize = [SDKUtil getStringFromRatio];
    NSString *height = [[videoSize componentsSeparatedByString:@"*"] lastObject];
    for (NSString *title in self.videoSizePopUpButton.itemTitles) {
        NSString *itemH = [[title componentsSeparatedByString:@"*"] lastObject];
        if ([itemH isEqualToString:height]) {
            [self.videoSizePopUpButton selectItemWithTitle:title];
        }
    }
    
    // 帧率
    NSString *fps = [NSString stringWithFormat:@"%d", vCfg.fps];
    [self.fpsPopUpButton selectItemWithTitle:fps];
    
    // 视频质量
    if (vCfg.maxQuality > 25) {
        self.picQualityButton.state = NSControlStateValueOff;
        self.fluencyButton.state = NSControlStateValueOn;
    } else {
        self.picQualityButton.state = NSControlStateValueOn;
        self.fluencyButton.state = NSControlStateValueOff;
    }
    
    // 增益，降噪，回声消除
    self.agcButton.state = audioCfg.agc;
    self.aecButton.state = audioCfg.aec;
    self.ansButton.state = audioCfg.ans;
}

- (IBAction)cameraValueChange:(NSPopUpButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    // short videoID = [cloudroomVideoMeeting getDefaultVideo:myUserID];
    
    NSInteger index = [sender indexOfSelectedItem];
    if (index == _curCameraIndex) {
        return;
    }
    
    if (index >= _cameraArray.count) {
        return;
    }
    
    _curCameraIndex = index;
    UsrVideoInfo *usrVideoInfo = [_cameraArray objectAtIndex:_curCameraIndex];
    [[CloudroomVideoMeeting shareInstance] setDefaultVideo:usrVideoInfo.userId videoID:usrVideoInfo.videoID];
    
//    for (UsrVideoInfo *usrVideoInfo in _cameraArray) {
//
//        NSLog(@"UsrVideoInfo: %d %@, %d %@",videoID, selectTitle, usrVideoInfo.videoID, usrVideoInfo.videoName);
//        if (videoID == usrVideoInfo.videoID && [usrVideoInfo.videoName isEqualToString:selectTitle]) {
//            // 选中当前的摄像头
//            return;
//        } else {
//            [[CloudroomVideoMeeting shareInstance] setDefaultVideo:usrVideoInfo.userId videoID:usrVideoInfo.videoID];
//        }
//    }
}

- (IBAction)micValueChange:(NSPopUpButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    
    NSString *selectItem = [sender titleOfSelectedItem];
    for (ADevInfo *devInfo in _micNames) {
        if ([devInfo.name isEqualToString:selectItem]) {
            audioCfg.micDevID = devInfo.devId; // 设置ID更可靠
            [cloudroomVideoMeeting setAudioCfg:audioCfg];
        }
    }
}

// 不需要调整
- (IBAction)micVolumeChange:(NSSlider *)sender {
//    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
//    BOOL success = [cloudroomVideoMeeting setMicVolume:sender.intValue];
//    NSLog(@"__setMicVolume %d", success);
}

- (IBAction)speakerValueChange:(NSPopUpButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    
    NSString *selectItem = [sender titleOfSelectedItem];
    for (ADevInfo *devInfo in _spkNames) {
        if ([devInfo.name isEqualToString:selectItem]) {
            audioCfg.spkDevID = devInfo.devId; // 设置ID更可靠
            [cloudroomVideoMeeting setAudioCfg:audioCfg];
        }
    }
}

- (IBAction)volumeChange:(NSSlider *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    BOOL success = [cloudroomVideoMeeting setSpeakerVolume:sender.intValue];
    NSLog(@"__setSpeakerVolume %d", success);
}

- (IBAction)videoSizeChange:(NSPopUpButton *)sender {
    NSString *title = [sender titleOfSelectedItem];
    title = [title stringByReplacingOccurrencesOfString:@"*" withString:@","];
    title = [NSString stringWithFormat:@"{%@}", title];
    CGSize videoSize = NSSizeFromString(title);
    
    [SDKUtil setRatio:videoSize];
}

- (IBAction)videoFpsChange:(NSPopUpButton *)sender {
    int fps = [[sender titleOfSelectedItem] intValue];
    
    [SDKUtil setFps:fps];
}

- (IBAction)pictureQualityFirst:(NSButton *)sender {
    // 设置默认优先级: 画质优先
    [SDKUtil setPriority:25 min:22];
    self.picQualityButton.state = NSControlStateValueOn;
    self.fluencyButton.state = NSControlStateValueOff;
}
- (IBAction)fluencyFirst:(NSButton *)sender {
    // 设置默认优先级: 流畅优先
    [SDKUtil setPriority:36 min:22];
    self.picQualityButton.state = NSControlStateValueOff;
    self.fluencyButton.state = NSControlStateValueOn;
}

- (IBAction)turnOnAgc:(NSButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    audioCfg.agc = sender.state == NSControlStateValueOn ? 1 : 0;
    [cloudroomVideoMeeting setAudioCfg:audioCfg];
    self.micphoneSlider.hidden = audioCfg.agc == 1;
}
- (IBAction)turnOnAec:(NSButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    audioCfg.aec = sender.state == NSControlStateValueOn ? 1 : 0;
    [cloudroomVideoMeeting setAudioCfg:audioCfg];
}
- (IBAction)turnOnAns:(NSButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    AudioCfg *audioCfg = [cloudroomVideoMeeting getAudioCfg];
    audioCfg.ans = sender.state == NSControlStateValueOn ? 1 : 0;
    [cloudroomVideoMeeting setAudioCfg:audioCfg];
}

@end
