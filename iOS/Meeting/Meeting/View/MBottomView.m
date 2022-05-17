//
//  MBottomView.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MBottomView.h"
#import "MeetingBtn.h"

@interface MBottomView ()

@property (nonatomic, weak) IBOutlet MeetingBtn *micBtn;
@property (nonatomic, weak) IBOutlet MeetingBtn *cameraBtn;
@property (nonatomic, weak) IBOutlet MeetingBtn *chatBtn;
@property (nonatomic, weak) IBOutlet MeetingBtn *excBtn;
@property (nonatomic, weak) IBOutlet MeetingBtn *ratioBtn;
@property (nonatomic, weak) IBOutlet MeetingBtn *frameBtn;
@property (nonatomic, weak) IBOutlet UIButton *exitBtn;

- (IBAction)clickBtnForMBottomView:(UIButton *)sender;

@end

@implementation MBottomView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - public method
- (void)updateMic:(BOOL)selected {
    [_micBtn setSelected:selected];
}

- (void)updateCamera:(BOOL)selected {
    [_cameraBtn setSelected:selected];
}

#pragma mark - selector
- (IBAction)clickBtnForMBottomView:(UIButton *)sender {
    switch ([sender tag]) {
        case MBottomViewBtnTypeMic: {
            sender.selected = !sender.selected;
            break;
        }
        case MBottomViewBtnTypeCamera: {
            sender.selected = !sender.selected;
            
            break;
        }
        case MBottomViewBtnTypeChat: {
            break;
        }
        case MBottomViewBtnTypeExCamera: {
            break;
        }
        case MBottomViewBtnTypeRatio: {
            break;
        }
        case MBottomViewBtnTypeExit: {
            break;
        }
        case MBottomViewBtnTypeFrame: {
            break;
        }
    }
    
    if (_response) {
        _response(self, sender);
    }
}

#pragma mark - private method
- (void)_commonSetup {
    [_micBtn setImage:[UIImage imageNamed:@"meeting_mic_close"] forState:UIControlStateSelected];
    [_micBtn setImage:[UIImage imageNamed:@"meeting_mic_open"] forState:UIControlStateNormal];
    [_micBtn setTitle:@"关闭麦克风" forState:UIControlStateNormal];
    [_micBtn setTitle:@"打开麦克风" forState:UIControlStateSelected];
    [_micBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_micBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_micBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_cameraBtn setImage:[UIImage imageNamed:@"meeting_camera_close"] forState:UIControlStateSelected];
    [_cameraBtn setImage:[UIImage imageNamed:@"meeting_camera_open"] forState:UIControlStateNormal];
    [_cameraBtn setTitle:@"关闭摄像头" forState:UIControlStateNormal];
    [_cameraBtn setTitle:@"打开摄像头" forState:UIControlStateSelected];
    [_cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_cameraBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_chatBtn setImage:[UIImage imageNamed:@"meeting_chat"] forState:UIControlStateNormal];
    [_chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
    [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_excBtn setImage:[UIImage imageNamed:@"meeting_camera_exchange"] forState:UIControlStateNormal];
    [_excBtn setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [_excBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_excBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_ratioBtn setImage:[UIImage imageNamed:@"meeting_ratio"] forState:UIControlStateNormal];
    [_ratioBtn setTitle:@"分辨率" forState:UIControlStateNormal];
    [_ratioBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ratioBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_exitBtn setBackgroundImage:[UIImage imageNamed:@"meeting_exit"] forState:UIControlStateNormal];
    
    [_frameBtn setImage:[UIImage imageNamed:@"meeting_frame"] forState:UIControlStateNormal];
    [_frameBtn setTitle:@"帧率" forState:UIControlStateNormal];
    [_frameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_frameBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [self setBackgroundColor:UIColorFromRGBA(23, 35, 50, 1.0)];
}
@end
