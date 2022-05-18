//
//  MemberCellView.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import "MemberCellView.h"

@implementation MemberCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    [super awakeFromNib];
   
}


//enum ASTATUS
//{
//    AUNKNOWN,
//    ANULL,
//    ACLOSE,
//    AOPEN,
//    AOPENING,    //请求开麦中
//    AACCEPTING    //接受他人开麦申请中
//};
//enum VSTATUS
//{
//    VUNKNOWN,
//    VNULL,
//    VCLOSE,
//    VOPEN,
//    VOPENING
//};

- (IBAction)microphoneAction:(NSButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    // 开麦
    if (_member.audioStatus == ACLOSE) {
        [cloudroomVideoMeeting openMic:_member.userId];
    }
    
    // 关麦
    if (_member.audioStatus == AOPEN) {
        [cloudroomVideoMeeting closeMic:_member.userId];
    }
}

- (IBAction)videoAction:(NSButton *)sender {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    // 开摄像头
    if (_member.videoStatus == VCLOSE) {
        [cloudroomVideoMeeting openVideo:_member.userId];
    }
    
    // 关摄像头
    if (_member.videoStatus == VOPEN) {
        [cloudroomVideoMeeting closeVideo:_member.userId];
    }
}


- (void)setMember:(MemberInfo *)member {
    _member = member;
    
    self.nameLabel.stringValue = member.nickName ? member.nickName : [NSString new];
    
    switch (member.audioStatus) {
        case AUNKNOWN:
        case ANULL:
        case ACLOSE:
            self.microphoneButton.image = [NSImage imageNamed:@"mic_mute"];
            break;
            
        case AOPEN:
            self.microphoneButton.image = [NSImage imageNamed:@"mic_open"];
            break;
            
        default:
            break;
    }
    
    
    switch (member.videoStatus) {
        case VUNKNOWN:
        case VNULL:
        case VCLOSE:
            self.videoButton.image = [NSImage imageNamed:@"video_close"];
            break;
            
        case VOPEN:
            self.videoButton.image = [NSImage imageNamed:@"video_open"];
        default:
            break;
    }
    
}

@end
