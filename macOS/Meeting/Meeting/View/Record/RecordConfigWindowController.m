//
//  RecordConfigWindowController.m
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/12/15.
//

#import "RecordConfigWindowController.h"
#import "PathUtil.h"

@interface RecordConfigWindowController () <NSWindowDelegate, CloudroomVideoMeetingCallBack>
@property (weak) IBOutlet NSTextField *fpsTextField;
@property (weak) IBOutlet NSTextField *bpsTextField;
@property (weak) IBOutlet NSPopUpButton *videoSizePopUpButton;
@property (weak) IBOutlet NSButton *localButton;
@property (weak) IBOutlet NSButton *svrMixerButton;
@property (weak) IBOutlet NSButton *startRecordButton;
@property (weak) IBOutlet NSButton *flowButton;
@property (weak) IBOutlet NSTextField *flowAddrTextField;
@end

@implementation RecordConfigWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}

- (BOOL)isSvrRecord {
    return self.svrMixerButton.state == NSControlStateValueOn;
}

- (void)checkLastCloudMixerInfo:(void (^)(BOOL))result {
    if (_mixerID) {
        return;
    }
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    
    NSString *info = [cloudroomVideoMeeting getAllCloudMixerInfo];
    NSArray *cloudMixerInfo = [info mj_JSONObject];
    for (NSDictionary *item in cloudMixerInfo) {
        NSString *owner = [item valueForKey:@"owner"];
        if ([owner isEqualToString:[cloudroomVideoMeeting getMyUserID]]) {
            _mixerID = [item valueForKey:@"ID"];
            MIXER_STATE state = [[item valueForKey:@"state"] intValue];
            if (state == RECORDING) {
                [cloudroomVideoMeeting destroyCloudMixer:_mixerID];
                self.svrMixerButton.state = NSControlStateValueOn;
                
                if (result) {
                    result(YES);
                }
            }
            break;
        }
    }
}

- (IBAction)checkLocalRecordAction:(id)sender {
    NSString *filePath = [PathUtil searchPathInCacheDir:@"CloudroomVideoSDK"];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:filePath]]];
}

- (IBAction)recordStyleAction:(NSButton *)sender {
    if (sender == self.localButton) {
        self.svrMixerButton.state = NSControlStateValueOff;
    }
    
    if (sender == self.svrMixerButton) {
        self.localButton.state = NSControlStateValueOff;
    }
}

- (IBAction)videoSizeChangeAction:(NSPopUpButton *)sender {
    switch ([sender indexOfSelectedItem]) {
        case 0:
            self.bpsTextField.stringValue = @"350000";
            break;
            
        case 1:
            self.bpsTextField.stringValue = @"500000";
            break;
            
        case 2:
            self.bpsTextField.stringValue = @"1000000";
            break;
            
        default:
            break;
    }
}

- (IBAction)startRecordAction:(id)sender {
    if (self.svrMixerButton.state == NSControlStateValueOn) {
        [self startSvrMixerRecord];
    }
    
    if (self.localButton.state == NSControlStateValueOn) {
        [self startLocalRecord];
    }
    
    [self close];
}

- (void)startLocalRecord {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    CRVIDEOSDK_ERR_DEF rslt = CRVIDEOSDK_NOERR;
    NSString *mixerID = @"1";
    
    MixerCfg *cfg = [[MixerCfg alloc] init];
    [cfg setFps:20];
    [cfg setDefaultQP:18];
    [cfg setGop:15*15];
    [cfg setDstResolution:[self getRecordSize]];
    [cfg setMaxBPS:[self.bpsTextField.stringValue intValue]];
    [cfg setFps:[self.fpsTextField.stringValue intValue]];
    
    MixerContent *recContent = nil;
    NSSize size = [self getRecordSize];
    if (_recordType == RECVTP_VIDEO) {
        NSMutableArray <UsrVideoId *> * watchableVideos = [cloudroomVideoMeeting getWatchableVideos];
        recContent = [RecordConfigWindowController generateVideoMixerContent:watchableVideos size:[self getRecordSize] splitScreen:_videoType];
    } else if (_recordType == RECVTP_MEDIA) {
        recContent = [RecordConfigWindowController generateMediaMixerContent:CGRectMake(0, 0, size.width, size.height)];
    } else if (_recordType == RECVTP_SCREEN) {
        recContent = [RecordConfigWindowController generateScreenMixerContent:CGRectMake(0, 0, size.width, size.height)];
    }
    rslt = [cloudroomVideoMeeting createLocMixer:mixerID cfg:cfg content:recContent];
    if(rslt != CRVIDEOSDK_NOERR)
    {
        [NSAlert alertMessage:[NSString stringWithFormat:@"创建本地录制失败:%d", rslt]];
        return;
    }
    
    NSMutableArray<OutputCfg*> *outputCfgs = [NSMutableArray array];
    OutputCfg* outputCfg = [[OutputCfg alloc]init];
    [outputCfg setFileName:[PathUtil searchPathInCacheDir:[NSString stringWithFormat:@"CloudroomVideoSDK/%@_Mac.mp4", [self getCurFileString]]]];
    [outputCfgs addObject:outputCfg];
    
    if(self.flowButton.state == NSControlStateValueOn)
    {
        OutputCfg* outputStearmCfg = [[OutputCfg alloc]init];
        [outputStearmCfg setType:OUT_LIVE];
        [outputStearmCfg setLiveUrl:self.flowAddrTextField.stringValue];
        [outputStearmCfg setLive:YES];
        [outputCfgs addObject:outputStearmCfg];
    }
    
    MixerOutput *mixerOutput = [[MixerOutput alloc]init];
    mixerOutput.outputs = outputCfgs;
    rslt = [cloudroomVideoMeeting addLocMixer:mixerID outputs:mixerOutput];
    
    
    if(rslt != CRVIDEOSDK_NOERR )
    {
        [NSAlert alertMessage:[NSString stringWithFormat:@"添加本地录制配置失败:%d", rslt]];
    } else {
        if (_startLocalRecordBlock) _startLocalRecordBlock();
    }
}

- (void)startSvrMixerRecord {
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        
    NSMutableDictionary *cloudMixerCfgDict = [NSMutableDictionary dictionary];
    [cloudMixerCfgDict setValue:[NSNumber numberWithInt:0] forKey:@"mode"];
    
    NSString *svrPathName = [NSString stringWithFormat:@"/%@/%@_Mac.mp4", [self getCurDirString], [self getCurFileString]];
    CGSize dstResolution = [self getRecordSize];
    // int maxBPS = [self.bpsTextField.text intValue];
    int fps = [self.fpsTextField.stringValue intValue];
    
    NSMutableDictionary *videoFileCfgDict = [NSMutableDictionary dictionary];
    [videoFileCfgDict setValue:svrPathName forKey:@"svrPathName"];
    [videoFileCfgDict setValue:[NSNumber numberWithInt:dstResolution.width] forKey:@"vWidth"];
    [videoFileCfgDict setValue:[NSNumber numberWithInt:dstResolution.height] forKey:@"vHeight"];
    [videoFileCfgDict setValue:[NSNumber numberWithInt:fps] forKey:@"vFps"];
    

    NSArray *recContent = nil;
    NSSize size = [self getRecordSize];
    if (_recordType == RECVTP_VIDEO) {
        NSMutableArray <UsrVideoId *> * watchableVideos = [cloudroomVideoMeeting getWatchableVideos];
        recContent = [RecordConfigWindowController generateCloudVideoMixerContent:watchableVideos size:[self getRecordSize] splitScreen:_videoType];
    } else if (_recordType == RECVTP_MEDIA) {
        recContent = [RecordConfigWindowController generateCloudMediaMixerContent:CGRectMake(0, 0, size.width, size.height)];
    } else if (_recordType == RECVTP_SCREEN) {
        recContent = [RecordConfigWindowController generateCloudRemoteScreenMixerContent:CGRectMake(0, 0, size.width, size.height)];
    }
    [videoFileCfgDict setValue:recContent forKey:@"layoutConfig"];
    
    [cloudMixerCfgDict setValue:videoFileCfgDict forKey:@"videoFileCfg"];
    
    NSString *cloudMixerCfg = [cloudMixerCfgDict mj_JSONString];
    NSString *mixerID = nil;
    CRVIDEOSDK_ERR_DEF err = [cloudroomVideoMeeting createCloudMixer:cloudMixerCfg rsltMixerID:&mixerID];
    if (mixerID.length <= 0) {
        NSLog(@"createCloudMixer:%d", err);
        return;
    }
    _mixerID = mixerID;
    
}

// 更新录制内容
- (void)updateRecContent:(REC_CONTENT_TYPE)type {
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];

    if (type == RECVTP_VIDEO) {
        
        NSMutableArray <UsrVideoId *> * watchableVideos = [cloudroomVideoMeeting getWatchableVideos];
        if (self.svrMixerButton.state == NSControlStateValueOn) {
            NSArray *recContent = [RecordConfigWindowController generateCloudVideoMixerContent:watchableVideos size:[self getRecordSize] splitScreen:_videoType];
            NSMutableDictionary *cloudMixerCfgDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *videoFileCfgDic = [NSMutableDictionary dictionary];
            [videoFileCfgDic setValue:recContent forKey:@"layoutConfig"];
            [cloudMixerCfgDic setValue:videoFileCfgDic forKey:@"videoFileCfg"];
            [cloudroomVideoMeeting updateCloudMixerContent:_mixerID cfg:[cloudMixerCfgDic mj_JSONString]];
        }
        
        if (self.localButton.state == NSControlStateValueOn) {
            MixerContent *recContent = [RecordConfigWindowController generateVideoMixerContent:watchableVideos size:[self getRecordSize] splitScreen:_videoType];
            [cloudroomVideoMeeting updateLocMixerContent:@"1" content:recContent];
        }
        
    } else if (type == RECVTP_MEDIA) {
        
        NSSize size = [self getRecordSize];
        if (self.svrMixerButton.state == NSControlStateValueOn) {
            NSArray *recContent = [RecordConfigWindowController generateCloudMediaMixerContent:CGRectMake(0, 0, size.width, size.height)];
            NSMutableDictionary *cloudMixerCfgDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *videoFileCfgDic = [NSMutableDictionary dictionary];
            [videoFileCfgDic setValue:recContent forKey:@"layoutConfig"];
            [cloudMixerCfgDic setValue:videoFileCfgDic forKey:@"videoFileCfg"];
            [cloudroomVideoMeeting updateCloudMixerContent:_mixerID cfg:[cloudMixerCfgDic mj_JSONString]];
        }
        
        if (self.localButton.state == NSControlStateValueOn) {
            MixerContent *recContent = [RecordConfigWindowController generateMediaMixerContent:CGRectMake(0, 0, size.width, size.height)];
            [cloudroomVideoMeeting updateLocMixerContent:@"1" content:recContent];
        }
        
    } else if (type == RECVTP_SCREEN) {
        
        NSSize size = [self getRecordSize];
        if (self.svrMixerButton.state == NSControlStateValueOn) {
            NSArray *recContent = [RecordConfigWindowController generateCloudRemoteScreenMixerContent:CGRectMake(0, 0, size.width, size.height)];
            NSMutableDictionary *cloudMixerCfgDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *videoFileCfgDic = [NSMutableDictionary dictionary];
            [videoFileCfgDic setValue:recContent forKey:@"layoutConfig"];
            [cloudMixerCfgDic setValue:videoFileCfgDic forKey:@"videoFileCfg"];
            [cloudroomVideoMeeting updateCloudMixerContent:_mixerID cfg:[cloudMixerCfgDic mj_JSONString]];
        }
        
        if (self.localButton.state == NSControlStateValueOn) {
            MixerContent *recContent = [RecordConfigWindowController generateScreenMixerContent:CGRectMake(0, 0, size.width, size.height)];
            [cloudroomVideoMeeting updateLocMixerContent:@"1" content:recContent];
        }
    }
}

+ (MixerContent *)generateVideoMixerContent:(NSMutableArray<UsrVideoId *> *)watchableVideos size:(NSSize)size splitScreen:(VideoWallType)splitScreen {

    NSMutableArray<RecContentItem *> *recordVideos = [NSMutableArray array];
    //云端录制最大支持720P
    CGFloat contentW = size.width;
    CGFloat contentH = size.height;
    
    NSInteger columns = 0;
    switch (splitScreen) {
        case Split_Two:
        case Split_Four:
            columns = 2;
            break;
            
        case Split_Six:
            columns = 3;
            break;
            
        default:
            break;
    }
    NSInteger rows = splitScreen/columns;
    NSInteger videosCount = videosCount = MIN(watchableVideos.count, splitScreen);

    CGFloat space = 2.0;
    CGFloat cameraW = (contentW - space*(columns - 1))/columns;
    CGFloat cameraH = cameraW*9/16 ;
    CGFloat cameraY = (contentH - cameraH*rows - space*(rows - 1))/2;
    for (NSInteger i = 0; i < rows; i++) {
        for (NSInteger j = 0; j < columns; j++) {
            NSInteger index = i*columns + j;
            if (index < videosCount) {
                UsrVideoId*leftID = (UsrVideoId*)[watchableVideos objectAtIndex:index];
                NSLog(@"record: userId %@, videoID %d", leftID.userId, leftID.videoID);
                CGRect cameraRect = (CGRect){j*cameraW + j*space, cameraY + i*cameraH + i*space,cameraW ,cameraH};
                RecVideoContentItem *video = [[RecVideoContentItem alloc] initWithRect:cameraRect userID:leftID.userId camID:leftID.videoID];
                [recordVideos addObject:video];
            }
        }
    }
    
    
    MixerContent *recContent = [[MixerContent alloc]init];
    recContent.contents = [recordVideos copy];
    
    return recContent;
}

+ (MixerContent *)generateMediaMixerContent:(CGRect)itemRect {
    NSMutableArray<RecContentItem *> *recordVideos = [NSMutableArray array];
    RecMediaContentItem *media = [[RecMediaContentItem alloc] initWithRect:itemRect];
    [recordVideos addObject:media];
    
    MixerContent *recContent = [[MixerContent alloc]init];
    recContent.contents = [recordVideos copy];
    
    return recContent;
}

// 屏幕录制分辨率配置建议至少720p，否则模糊
+ (MixerContent *)generateScreenMixerContent:(CGRect)itemRect {
    NSMutableArray<RecContentItem *> *recordVideos = [NSMutableArray array];
    RecScreenContentItem *media = [[RecScreenContentItem alloc] initWithRect:itemRect];
    [recordVideos addObject:media];
    
    MixerContent *recContent = [[MixerContent alloc]init];
    recContent.contents = [recordVideos copy];
    
    return recContent;
}

#pragma mark - 云端录制数据
+ (NSArray *)generateCloudVideoMixerContent:(NSMutableArray<UsrVideoId *> *)watchableVideos size:(NSSize)size splitScreen:(VideoWallType)splitScreen {

    NSMutableArray *recordVideos = [NSMutableArray array];
    //云端录制最大支持720P
    CGFloat contentW = size.width;
    CGFloat contentH = size.height;
    
    NSInteger columns = 0;
    switch (splitScreen) {
        case Split_Two:
        case Split_Four:
            columns = 2;
            break;
            
        case Split_Six:
            columns = 3;
            break;
            
        default:
            break;
    }
    NSInteger rows = splitScreen/columns;
    NSInteger videosCount = videosCount = MIN(watchableVideos.count, splitScreen);

    CGFloat space = 2.0;
    CGFloat cameraW = (contentW - space*(columns - 1))/columns;
    CGFloat cameraH = cameraW*9/16 ;
    CGFloat cameraY = (contentH - cameraH*rows - space*(rows - 1))/2;
    for (NSInteger i = 0; i < rows; i++) {
        for (NSInteger j = 0; j < columns; j++) {
            NSInteger index = i*columns + j;
            if (index < videosCount) {
                UsrVideoId*leftID = (UsrVideoId*)[watchableVideos objectAtIndex:index];
                NSLog(@"record: userId %@, videoID %d", leftID.userId, leftID.videoID);
                CGRect cameraRect = (CGRect){j*cameraW + j*space, cameraY + i*cameraH + i*space,cameraW ,cameraH};
                NSMutableDictionary *config = [NSMutableDictionary dictionary];
                [config setValue:[NSNumber numberWithInt:0] forKey:@"type"];
                [config setValue:[NSNumber numberWithFloat:cameraRect.origin.y] forKey:@"top"];
                [config setValue:[NSNumber numberWithFloat:cameraRect.origin.x] forKey:@"left"];
                [config setValue:[NSNumber numberWithFloat:cameraRect.size.width] forKey:@"width"];
                [config setValue:[NSNumber numberWithFloat:cameraRect.size.height] forKey:@"height"];
                [config setValue:[NSNumber numberWithInt:1] forKey:@"keepAspectRatio"];
                
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:[NSString stringWithFormat:@"%@.%d", leftID.userId, leftID.videoID] forKey:@"camid"];
                [config setValue:param forKey:@"param"];
                [recordVideos addObject:config];
            }
        }
    }
    
    return [recordVideos copy];
}

+ (NSArray *)generateCloudMediaMixerContent:(CGRect)itemRect {
    NSMutableArray *recordVideos = [NSMutableArray array];
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setValue:[NSNumber numberWithInt:RECVTP_MEDIA] forKey:@"type"];
    [item setValue:[NSNumber numberWithFloat:itemRect.origin.y] forKey:@"top"];
    [item setValue:[NSNumber numberWithFloat:itemRect.origin.x] forKey:@"left"];
    [item setValue:[NSNumber numberWithFloat:itemRect.size.width] forKey:@"width"];
    [item setValue:[NSNumber numberWithFloat:itemRect.size.height] forKey:@"height"];
    [item setValue:[NSNumber numberWithInt:1] forKey:@"keepAspectRatio"];
    
    [recordVideos addObject:item];
    
    return [recordVideos copy];
}

// 屏幕录制分辨率配置建议至少720p，否则模糊
+ (NSArray *)generateCloudRemoteScreenMixerContent:(CGRect)itemRect {
    NSMutableArray *recordVideos = [NSMutableArray array];
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setValue:[NSNumber numberWithInt:RECVTP_REMOTE_SCREEN] forKey:@"type"];
    [item setValue:[NSNumber numberWithFloat:itemRect.origin.y] forKey:@"top"];
    [item setValue:[NSNumber numberWithFloat:itemRect.origin.x] forKey:@"left"];
    [item setValue:[NSNumber numberWithFloat:itemRect.size.width] forKey:@"width"];
    [item setValue:[NSNumber numberWithFloat:itemRect.size.height] forKey:@"height"];
    [item setValue:[NSNumber numberWithInt:1] forKey:@"keepAspectRatio"];
    
    [recordVideos addObject:item];
    
    return [recordVideos copy];
}

- (NSSize)getRecordSize {
    NSInteger index = [self.videoSizePopUpButton indexOfSelectedItem];
    if(index == 0)
    {
        return (CGSize){640, 360};
    }
    else if(index == 1)
    {
        return (CGSize){848, 480};
    }
    else if(index == 2)
    {
        return (CGSize){1280, 720};
    }
    return NSMakeSize(0, 0);
}

- (NSString *)getCurDirString {
    NSDate *curDate = [NSDate date];
    NSCalendarUnit uints = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components =  [[NSCalendar currentCalendar] components:uints  fromDate:curDate];
    
    return [NSString stringWithFormat:@"%04zd-%02zd-%02zd", components.year, components.month, components.day];
}

- (NSString *)getCurFileString {
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSInteger curYear = [[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    NSInteger curMonth = [[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"dd"];
    NSInteger curDay = [[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"HH"];
    NSInteger curHour = [[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"mm"];
    NSInteger curMinute = [[formatter stringFromDate:date]integerValue];
    [formatter setDateFormat:@"ss"];
    NSInteger curSecond = [[formatter stringFromDate:date] integerValue];
    
    return [NSString stringWithFormat:@"%04zd-%02zd-%02zd_%02zd-%02zd-%02zd", curYear, curMonth, curDay, curHour, curMinute, curSecond];
}

@end
