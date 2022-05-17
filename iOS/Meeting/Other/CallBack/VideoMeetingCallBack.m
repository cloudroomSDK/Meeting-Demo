//
//  VideoMeetingCallBack.m
//  VideoCall
//
//  Created by king on 2017/6/7.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import "VideoMeetingCallBack.h"

@interface VideoMeetingCallBack ()

@end

@implementation VideoMeetingCallBack
// 入会成功；(入会失败，将自动发起releaseCall）
- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code
{
//    MLog(@"code:%u", code);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:enterMeetingRslt:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self enterMeetingRslt:code];
        }
    });
}

// user进入了会话
- (void)userEnterMeeting:(NSString *)userID
{
//    MLog(@"userID:%@", userID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:userEnterMeeting:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self userEnterMeeting:userID];
        }
    });
}

- (void)userLeftMeeting:(NSString *)userID
{
//    MLog(@"userID:%@", userID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:userLeftMeeting:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self userLeftMeeting:userID];
        }
    });
}

// 创建房间
- (void)createMeetingSuccess:(int)meetID password:(NSString *)password cookie:(NSString *)cookie
{
//    MLog(@"meetID:%d password:%@ cookie:%@", meetID, password, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:createMeetingSuccess:password:cookie:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self createMeetingSuccess:meetID password:password cookie:cookie];
        }
    });
}

- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
//    MLog(@"sdkErr:%u cookie:%@", sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:createMeetingFail:cookie:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self createMeetingFail:sdkErr cookie:cookie];
        }
    });
}

// 结束房间的结果
- (void)stopMeetingRslt:(CRVIDEOSDK_ERR_DEF)code
{
//    MLog(@"code:%u", code);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:stopMeetingRslt:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self stopMeetingRslt:code];
        }
    });
}

// 房间被结束了
- (void)meetingStopped
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackMeetingStopped:)]) {
            [_videoMeetingDelegate videoMeetingCallBackMeetingStopped:self];
        }
    });
}

// 房间掉线
- (void)meetingDropped
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackMeetingDropped:)]) {
            [_videoMeetingDelegate videoMeetingCallBackMeetingDropped:self];
        }
    });
}

// 最新网络评分0~10(10分为最佳网络)
-(void)netStateChanged:(int)level
{
//    MLog(@"level:%d", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:netStateChanged:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self netStateChanged:level];
        }
    });
}

// 麦声音强度更新(level取值0~10)
- (void)micEnergyUpdate:(NSString *)userID oldLevel:(int)oldLevel newLevel:(int)newLevel
{
//    MLog(@"userID:%@ oldLevel:%d newLevel:%d", userID, oldLevel, newLevel);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:micEnergyUpdate:oldLevel:newLevel:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self micEnergyUpdate:userID oldLevel:oldLevel newLevel:newLevel];
        }
    });
}

// 本地音频设备有变化
- (void)audioDevChanged
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackAudioDevChanged:)]) {
            [_videoMeetingDelegate videoMeetingCallBackAudioDevChanged:self];
        }
    });
}

// 音频设备状态变化
- (void)audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus
{
//    MLog(@"userID:%@ oldStatus:%d newStatus:%d", userID, oldStatus, newStatus);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:audioStatusChanged:oldStatus:newStatus:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self audioStatusChanged:userID oldStatus:oldStatus newStatus:newStatus];
        }
    });
}

// 视频设备状态变化
- (void)videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus
{
//    MLog(@"userID:%@ oldStatus:%d newStatus:%d", userID, oldStatus, newStatus);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:videoStatusChanged:oldStatus:newStatus:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self videoStatusChanged:userID oldStatus:oldStatus newStatus:newStatus];
        }
    });
}

- (void)openVideoRslt:(NSString *)devID success:(BOOL)bSuccess
{
//    MLog(@"bSuccess:%@", bSuccess ? @"YES" : @"NO");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:openVideoRslt:success:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self openVideoRslt:devID success:bSuccess];
        }
    });
}

// 成员有新的视频图像数据到来(通过GetVideoImg获取）
- (void)notifyVideoData:(UsrVideoId *)userID frameTime:(long)frameTime
{
    // MLog(@"userID.userId:%@ userID.videoID:%d frameTime:%ld", userID.userId, userID.videoID, frameTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyVideoData:frameTime:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyVideoData:userID frameTime:frameTime];
        }
    });
}

// 本地视频设备有变化
- (void)videoDevChanged:(NSString *)userID
{
//    MLog(@"userID:%@", userID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:videoDevChanged:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self videoDevChanged:userID];
        }
    });
}

- (void)defVideoChanged:(NSString *)userID videoID:(short)videoID
{
//    MLog(@"userID:%@ videoID:%d", userID, videoID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:defVideoChanged:videoID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self defVideoChanged:userID videoID:videoID];
        }
    });
}

// 屏幕共享操作通知
- (void)notifyScreenShareStarted
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackNotifyScreenShareStarted:)]) {
            [_videoMeetingDelegate videoMeetingCallBackNotifyScreenShareStarted:self];
        }
    });
}

- (void)notifyScreenShareStopped
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackNotifyScreenShareStopped:)]) {
            [_videoMeetingDelegate videoMeetingCallBackNotifyScreenShareStopped:self];
        }
    });
}

// 屏幕共享数据更新,用户收到该回调消息后应该调用getShareScreenDecodeImg获取最新的共享数据
- (void)notifyScreenShareData:(NSString *)userID changedRect:(CGRect)changedRect frameSize:(CGSize)size
{
    // MLog(@"userID:%@ changedRect:%@ size:%@", userID, NSStringFromCGRect(changedRect), NSStringFromCGSize(size));
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyScreenShareData:changedRect:frameSize:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyScreenShareData:userID changedRect:changedRect frameSize:size];
        }
    });
}

// IM消息发送结果
- (void)sendIMmsgRlst:(NSString *)taskID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
//    MLog(@"taskID:%@ sdkErr:%u cookie:%@", taskID, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:sendIMmsgRlst:sdkErr:cookie:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self sendIMmsgRlst:taskID sdkErr:sdkErr cookie:cookie];
        }
    });
}

// 通知收到文本消息
- (void)notifyIMmsg:(NSString *)romUserID text:(NSString *)text sendTime:(int)sendTime
{
//    MLog(@"romUserID:%@ text:%@", romUserID, text);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyIMmsg:text:sendTime:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyIMmsg:romUserID text:text sendTime:sendTime];
        }
    });
}

// 影音开始通知
- (void)notifyMediaStart:(NSString *)userid
{
//    MLog(@"userid:%@", userid);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyMediaStart:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyMediaStart:userid];
        }
    });
}

// 影音停止播放的通知
- (void)notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason
{
//    MLog(@"userid:%@ reason:%u", userid, reason);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyMediaStop:reason:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyMediaStop:userid reason:reason];
        }
    });
}

// 影音暂停播放的通知
- (void)notifyMediaPause:(NSString *)userid bPause:(BOOL)bPause
{
//    MLog(@"userid:%@ bPause:%@", userid, bPause ? @"YES" : @"NO");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyMediaPause:bPause:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyMediaPause:userid bPause:bPause];
        }
    });
}

// 视频帧数据已解好
- (void)notifyMemberMediaData:(NSString *)userid curPos:(int)curPos
{
//    MLog(@"userid:%@", userid);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyMemberMediaData:curPos:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyMemberMediaData:userid curPos:curPos];
        }
    });
}

// 视频墙分屏模式回调
- (void)notifyVideoWallMode:(int)wallMode
{
//    MLog(@"wallMode:%d", wallMode);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyVideoWallMode:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyVideoWallMode:wallMode];
        }
    });
}


- (void)notifyScreenMarkStarted
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackNotifyScreenMarkStarted:)]) {
            [_videoMeetingDelegate videoMeetingCallBackNotifyScreenMarkStarted:self];
        }
    });
}

- (void)notifyScreenMarkStopped
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackNotifyScreenMarkStopped:)]) {
            [_videoMeetingDelegate videoMeetingCallBackNotifyScreenMarkStopped:self];
        }
    });
}

- (void)enableOtherMark:(BOOL)enable
{
//    MLog(@"enable:%@", enable ? @"YES" : @"NO");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:enableOtherMark:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self enableOtherMark:enable];
        }
    });
}

- (void)sendMarkData:(MarkData *)markData
{
//    MLog(@"markData.termid:%hd markData.termidSN:%hd markData.color:%d markData.mousePosSeq:%zd", markData.termid, markData.termidSN, markData.color, [markData.mousePosSeq count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:sendMarkData:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self sendMarkData:markData];
        }
    });
}

- (void)sendAllMarkData:(NSArray<MarkData *> *)markDatas
{
//    for (MarkData *markData in markDatas) {
//        MLog(@"markData.termid:%hd markData.termidSN:%hd markData.color:%d markData.mousePosSeq:%zd", markData.termid, markData.termidSN, markData.color, [markData.mousePosSeq count]);
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:sendAllMarkData:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self sendAllMarkData:markDatas];
        }
    });
}

- (void)clearAllMarks;
{
//    MLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBackClearAllMarks:)]) {
            [_videoMeetingDelegate videoMeetingCallBackClearAllMarks:self];
        }
    });
}

/* 白板 (king 20180716) */
- (void)notifyInitBoards:(NSArray<SubPageInfo *> *)boards {
    for (SubPageInfo *subPageInfo in boards) {
        MLog(@"termID:%d, localID:%d, title:%@, width:%d, height:%d, pageCount:%d", subPageInfo.boardID.termID, subPageInfo.boardID.localID, subPageInfo.title, subPageInfo.width, subPageInfo.height, subPageInfo.pageCount);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyInitBoards:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyInitBoards:boards];
        }
    });
}

- (void)notifyInitBoardPageDat:(SubPage *)boardID boardPageNo:(int)boardPageNo bkImgID:(NSString *)bkImgID elements:(NSString *)elements operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, boardPageNo:%d, bkImgID:%@, elements:%@, operatorID:%@", boardID.termID, boardID.localID, boardPageNo, bkImgID, elements, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyInitBoardPageDat:boardPageNo:bkImgID:elements:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyInitBoardPageDat:boardID boardPageNo:boardPageNo bkImgID:bkImgID elements:elements operatorID:operatorID];
        }
    });
}

- (void)notifyCreateBoard:(SubPageInfo *)board operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, title:%@, width:%d, height:%d, pageCount:%d operatorID:%@", board.boardID.termID, board.boardID.localID, board.title, board.width, board.height, board.pageCount, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyCreateBoard:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyCreateBoard:board operatorID:operatorID];
        }
    });
}

- (void)notifyCloseBoard:(SubPage *)boardID operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, operatorID:%@", boardID.termID, boardID.localID, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyCloseBoard:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyCloseBoard:boardID operatorID:operatorID];
        }
    });
}

- (void)notifyAddBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, boardPageNo:%d, element:%@, operatorID:%@", boardID.termID, boardID.localID, boardPageNo, element, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyAddBoardElement:boardPageNo:element:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyAddBoardElement:boardID boardPageNo:boardPageNo element:element operatorID:operatorID];
        }
    });
}

- (void)notifyModifyBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, boardPageNo:%d, element:%@, operatorID:%@", boardID.termID, boardID.localID, boardPageNo, element, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyModifyBoardElement:boardPageNo:element:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyModifyBoardElement:boardID boardPageNo:boardPageNo element:element operatorID:operatorID];
        }
    });
}

- (void)notifyDelBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementIDs:(NSArray<NSString *> *)elementIDs operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, boardPageNo:%d, elementIDs:%@, operatorID:%@", boardID.termID, boardID.localID, boardPageNo, elementIDs, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyDelBoardElement:boardPageNo:elementIDs:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyDelBoardElement:boardID boardPageNo:boardPageNo elementIDs:elementIDs operatorID:operatorID];
        }
    });
}

- (void)notifyMouseHotSpot:(SubPage *)boardID boardPageNo:(int)boardPageNo x:(int)x y:(int)y operatorID:(NSString *)operatorID {
    MLog(@"termID:%d, localID:%d, boardPageNo:%d, x:%d, y:%d, operatorID:%@", boardID.termID, boardID.localID, boardPageNo, x, y, operatorID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyMouseHotSpot:boardPageNo:x:y:operatorID:)]) {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyMouseHotSpot:boardID boardPageNo:boardPageNo x:x y:y operatorID:operatorID];
        }
    });
}

- (void)notifyMainVideo:(NSString *)userID {}


- (void)notifyMediaOpened:(long)totalTime size:(CGSize)picSZ {}


- (void)notifyPlayPosSetted:(int)setPTS {}


- (void)notifyRecordFileStateChanged:(NSString *)fileName state:(REC_FILE_STATE)state {}


- (void)notifyRecordFileUploadProgress:(NSString *)fileName percent:(int)percent {}


- (void)recordErr:(REC_ERR_TYPE)sdkErr {}


- (void)recordStateChanged:(MIXER_STATE)state {}


- (void)svrRecVideosChanged:(NSArray<RecContentItem *> *)videoIDs {}


- (void)svrRecordStateChanged:(MIXER_STATE)state err:(CRVIDEOSDK_ERR_DEF)sdkErr {}


- (void)uploadRecordFile:(NSString *)fileName err:(CRVIDEOSDK_ERR_DEF)sdkErr {}


- (void)uploadRecordFileSuccess:(NSString *)fileName fileUrl:(NSString *)fileUrl {}


-(void)setNickNameRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userid:(NSString*)userid newName:(NSString*)newName{
    
    MLog(@"sdkErr:%u userid:%@ newName:%@ ", sdkErr, userid,newName);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:setNickNameRsp:userid:newName:)])
        {
            [_videoMeetingDelegate videoMeetingCallBack:self setNickNameRsp:sdkErr userid:userid newName:newName];
        }
    });
    
}

- (void)notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName
{
    MLog(@"userid:%@ oldName:%@ newName:%@ ",userid,oldName,newName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyNickNameChanged:oldName:newName:)])
        {
            [_videoMeetingDelegate videoMeetingCallBack:self notifyNickNameChanged:userid oldName:oldName newName:newName];
        }
    });
}


//通知查询文档列表结果
-(void)listNetDiskDocFileRslt:(NSString*)dir err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(NetDiskDocDir*)rslt
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
         if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:listNetDiskDocFileRslt:err:rslt:)])
         {
             
             [_videoMeetingDelegate videoMeetingCallBack:self listNetDiskDocFileRslt:dir err:sdkErr rslt:rslt];
         }
    });
}

//通知查询文档转换页结果
-(void)getNetDiskDocFilePageInfoRslt:(NSString*)svrPathFileName err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(GetDocPageInfoRslt*)rslt
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:getNetDiskDocFilePageInfoRslt:err:rslt:)])
        {
            
            [_videoMeetingDelegate videoMeetingCallBack:self getNetDiskDocFilePageInfoRslt:svrPathFileName err:sdkErr rslt:rslt];
        }
    });
}

//通知文档传输进度
-(void)notifyNetDiskDocFileTrsfProgress:(NSString*)svrPathFileName finished:(int)finished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMeetingDelegate respondsToSelector:@selector(videoMeetingCallBack:notifyNetDiskDocFileTrsfProgress:finished:)])
        {
            
            [_videoMeetingDelegate videoMeetingCallBack:self notifyNetDiskDocFileTrsfProgress:svrPathFileName finished:finished];
        }
        
    });
}

@end
