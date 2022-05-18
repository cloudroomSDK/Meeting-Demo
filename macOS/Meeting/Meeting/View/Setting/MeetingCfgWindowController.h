//
//  MeetingCfgWindowController.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/18.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingCfgWindowController : NSWindowController
@property (nonatomic, copy) NSArray<UsrVideoInfo *> *cameraArray; /**< 摄像头集合 */
@end

NS_ASSUME_NONNULL_END
