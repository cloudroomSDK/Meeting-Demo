//
//  UIManage.h
//  Record(all)
//
//  Created by LyuBook on 2019/12/26.
//  Copyright © 2019 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VideoWallType)
{
     Split_Two = 2,
     Split_Four = 4,
     Split_Six = 6,
};

@interface UIManage : NSObject

@property (copy, nonatomic)  NSString *usrID; 
@property (copy, nonatomic)  NSString *currentMeetID;
@property (assign,nonatomic) VideoWallType videoWallType;

+ (instancetype)shareInstance;

- (NSString *)getCurDirString;
@end

NS_ASSUME_NONNULL_END
