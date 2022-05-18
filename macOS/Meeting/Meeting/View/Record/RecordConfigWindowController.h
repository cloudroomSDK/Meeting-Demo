//
//  RecordConfigWindowController.h
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/12/15.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordConfigWindowController : NSWindowController
@property (nonatomic, assign) BOOL isSvrRecord;
@property (nonatomic, copy) void (^startLocalRecordBlock)(void);
@property (nonatomic, copy) void (^startCloudRecordBlock)(NSString *mixerID);
@property (nonatomic, assign) VideoWallType videoType;
@property (nonatomic, assign) REC_CONTENT_TYPE recordType;
@property (nonatomic, copy) NSString *mixerID;

// 更新录制内容（如果要跟随共享变化）
- (void)updateRecContent:(REC_CONTENT_TYPE)type;

- (void)checkLastCloudMixerInfo:(void (^)(BOOL cloudMixer))result;

@end

NS_ASSUME_NONNULL_END
