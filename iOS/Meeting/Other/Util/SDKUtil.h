//
//  SDKUtil.h
//  Meeting
//
//  Created by king on 2018/7/4.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKUtil : NSObject

+ (void)openLocalMic;
+ (void)closeLocalMic;
+ (void)openLocalCamera;
+ (void)closeLocalCamera;
+ (BOOL)isLocalCameraOpen;

+ (void)setRatio:(CGSize)size;
+ (void)setFps:(int)fps;
+ (void)setPriority:(int)max min:(int)min;

+ (NSString *)getStringFromRatio;
+ (NSString *)getStringFromFrame;

+ (VIDEO_STATUS)getLocalCameraStatus;
+ (AUDIO_STATUS)getLocalMicStatus;

+(CGSize)getRatioFromString:(NSString*)ratioStr;

@end
