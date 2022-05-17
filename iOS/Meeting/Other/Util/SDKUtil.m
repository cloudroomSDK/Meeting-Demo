//
//  SDKUtil.m
//  Meeting
//
//  Created by king on 2018/7/4.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "SDKUtil.h"

@implementation SDKUtil
/* 打开本地麦克风 */
+ (void)openLocalMic {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    AUDIO_STATUS status = [cloudroomVideoMeeting getAudioStatus:myUserID];
    
    if (status != AOPEN && status != AOPENING) {
        [cloudroomVideoMeeting openMic:myUserID];
    }
}

/* 关闭本地麦克风 */
+ (void)closeLocalMic {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    AUDIO_STATUS status = [cloudroomVideoMeeting getAudioStatus:myUserID];
    
    if (status == AOPEN || status == AOPENING) {
        [cloudroomVideoMeeting closeMic:myUserID];
    }
}

/* 打开本地摄像头 */
+ (void)openLocalCamera {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    VIDEO_STATUS status = [cloudroomVideoMeeting getVideoStatus:myUserID];
    
    if (status != VOPEN && status != VOPENING) {
        [cloudroomVideoMeeting openVideo:myUserID];
    }
}

/* 关闭本地摄像头 */
+ (void)closeLocalCamera {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    VIDEO_STATUS status = [cloudroomVideoMeeting getVideoStatus:myUserID];
    
    if (status == VOPEN || status == VOPENING) {
        [cloudroomVideoMeeting closeVideo:myUserID];
    }
}

+ (BOOL)isLocalCameraOpen {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    VIDEO_STATUS status = [cloudroomVideoMeeting getVideoStatus:myUserID];
    
    return status == VOPEN || status == VOPENING;
}

+ (void)setRatio:(CGSize)size {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    
    [vCfg setSize:size];
    
    [cloudroomVideoMeeting setVideoCfg:vCfg];
}

+ (void)setFps:(int)fps {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    
    [vCfg setFps:fps];
    
    [cloudroomVideoMeeting setVideoCfg:vCfg];
}

int* f()
{
    int a= 10;
    return &a;
}

+ (void)setPriority:(int)max min:(int)min {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    
    // 画质优先(max: 25 min: 22)
    // 速度优先(max: 36 min: 22)
    [vCfg setMaxQuality:max];
    [vCfg setMinQuality:min];
    
    [cloudroomVideoMeeting setVideoCfg:vCfg];
}


+ (NSString *)getStringFromRatio {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    NSString *result = [NSString stringWithFormat:@"%d*%d",(int)vCfg.size.height,(int)vCfg.size.height];
 
    return result;
}

+ (NSString *)getStringFromFrame {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    VideoCfg *vCfg = [cloudroomVideoMeeting getVideoCfg];
    return [NSString stringWithFormat:@"%d", vCfg.fps];
}


+ (VIDEO_STATUS)getLocalCameraStatus {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    
    return [cloudroomVideoMeeting getVideoStatus:myUserID];
}

+ (AUDIO_STATUS)getLocalMicStatus {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *myUserID = [cloudroomVideoMeeting getMyUserID];
    
    return [cloudroomVideoMeeting getAudioStatus:myUserID];
}

+(CGSize)getRatioFromString:(NSString*)ratioStr
{
    CGSize result;
    
    if ([ratioStr isEqualToString:@"360*360"]) {
        result = CGSizeMake(360, 360);
    } else if ([ratioStr isEqualToString:@"480*480"]) {
        result = CGSizeMake(480, 480);
    } else if ([ratioStr isEqualToString:@"720*720"]) {
        result = CGSizeMake(720, 720);
    }
    
    return result;
}
@end
