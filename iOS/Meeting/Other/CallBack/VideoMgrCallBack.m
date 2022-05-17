//
//  VideoMgrCallBack.m
//  VideoCall
//
//  Created by king on 2017/6/7.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import "VideoMgrCallBack.h"

@interface VideoMgrCallBack ()

@end

@implementation VideoMgrCallBack
// 登录响应
- (void)loginSuccess:(NSString *)usrID cookie:(NSString *)cookie
{
    MLog(@"usrID:%@, cookie:%@", usrID, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:loginSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self loginSuccess:usrID cookie:cookie];
        }
    });
}

- (void)loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sdkErr:%u, cookie:%@", sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:loginFail:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self loginFail:sdkErr cookie:cookie];
        }
    });
}

// 掉线通知
- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr
{
    MLog(@"sdkErr:%u", sdkErr);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:lineOff:)]) {
            [_videoMgrDelegate videoMgrCallBack:self lineOff:sdkErr];
        }
    });
}

// 客户端免打扰状态响应
- (void)setDNDStatusSuccess:(NSObject *)cookie
{
    MLog(@"cookie:%@", cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:setDNDStatusSuccess:)]) {
            [_videoMgrDelegate videoMgrCallBack:self setDNDStatusSuccess:cookie];
        }
    });
}

- (void)setDNDStatusFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sdkErr:%u cookie:%@", sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:setDNDStatusFail:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self setDNDStatusFail:sdkErr cookie:cookie];
        }
    });
}

// 创建房间
- (void)createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie
{
    MLog(@"meetInfo.ID:%d meetInfo.pswd:%@ meetInfo.subject:%@ meetInfo.pubMeetUrl:%@ cookie:%@", meetInfo.ID, meetInfo.pswd, meetInfo.subject, meetInfo.pubMeetUrl, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:createMeetingSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self createMeetingSuccess:meetInfo cookie:cookie];
        }
    });
}

- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sdkErr:%u cookie:%@", sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:createMeetingFail:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self createMeetingFail:sdkErr cookie:cookie];
        }
    });
}

- (void)getMeetingListSuccess:(NSArray <MeetInfo *> *)meetList cookie:(NSString *)cookie
{
    MLog(@"meetList.count:%zd cookie:%@", meetList.count, cookie);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:getMeetingListSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self getMeetingListSuccess:meetList cookie:cookie];
        }
    });
}

- (void)getMeetingListFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:getMeetingListFail:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self getMeetingListFail:sdkErr cookie:cookie];
        }
    });
}

// 邀请他人参会响应
- (void)callSuccess:(NSString *)callID cookie:(NSString *)cookie
{
    MLog(@"callID:%@ cookie:%@", callID, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:callSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self callSuccess:callID cookie:cookie];
        }
    });
}

- (void)callFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"callID:%@ sdkErr:%u cookie:%@", callID, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:callFail:errCode:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self callFail:callID errCode:sdkErr cookie:cookie];
        }
    });
}

// 接受他人邀请响应
- (void)acceptCallSuccess:(NSString *)callID cookie:(NSString *)cookie
{
    MLog(@"callID:%@ cookie:%@", callID, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:acceptCallSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self acceptCallSuccess:callID cookie:cookie];
        }
    });
}

- (void)acceptCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"callID:%@ sdkErr:%u cookie:%@", callID, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:acceptCallFail:errCode:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self acceptCallFail:callID errCode:sdkErr cookie:cookie];
        }
    });
}

// 拒绝他人邀请响应
- (void)rejectCallSuccess:(NSString *)callID cookie:(NSString *)cookie
{
    MLog(@"callID:%@ cookie:%@", callID, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:rejectCallSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self rejectCallSuccess:callID cookie:cookie];
        }
    });
}

- (void)rejectCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"callID:%@ sdkErr:%u cookie:%@", callID, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:rejectCallFail:errCode:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self rejectCallFail:callID errCode:sdkErr cookie:cookie];
        }
    });
}

// 拆除呼叫
- (void)hangupCallSuccess:(NSString *)callID cookie:(NSString *)cookie
{
    MLog(@"callID:%@ cookie:%@", callID, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:hangupCallSuccess:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self hangupCallSuccess:callID cookie:cookie];
        }
    });
}

-(void)hangupCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"callID:%@ sdkErr:%u cookie:%@", callID, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:hangupCallFail:errCode:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self hangupCallFail:callID errCode:sdkErr cookie:cookie];
        }
    });
}

// 服务端通知被邀请
- (void)notifyCallIn:(NSString *)callID meetInfo:(MeetInfo *)meetInfo callerID:(NSString *)callerID usrExtDat:(NSString *)usrExtDat
{
    MLog(@"callID:%@ meetInfo.ID:%d meetInfo.pswd:%@ meetInfo.subject:%@ meetInfo.pubMeetUrl:%@ callerID:%@ usrExtDat:%@", callID, meetInfo.ID, meetInfo.pswd, meetInfo.subject, meetInfo.pubMeetUrl, callerID, usrExtDat);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCallIn:meetInfo:callerID:usrExtDat:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCallIn:callID meetInfo:meetInfo callerID:callerID usrExtDat:usrExtDat];
        }
    });
}

// 服务端通知房间邀请被接受
- (void)notifyCallAccepted:(NSString *)callID meetInfo:(MeetInfo *)meetInfo usrExtDat:(NSString *)usrExtDat
{
    MLog(@"callID:%@ meetInfo.ID:%d meetInfo.pswd:%@ meetInfo.subject:%@ meetInfo.pubMeetUrl:%@", callID, meetInfo.ID, meetInfo.pswd, meetInfo.subject, meetInfo.pubMeetUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCallAccepted:meetInfo:usrExtDat:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCallAccepted:callID meetInfo:meetInfo usrExtDat:usrExtDat];
        }
    });
}

// 服务端通知邀请被拒绝
- (void)notifyCallRejected:(NSString *)callID reason:(CRVIDEOSDK_ERR_DEF)reason usrExtDat:(NSString *)usrExtDat
{
    MLog(@"callID:%@ reason:%u", callID, reason);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCallRejected:reason:usrExtDat:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCallRejected:callID reason:reason usrExtDat:usrExtDat];
        }
    });
}

// 服务端通知呼叫被结束
- (void)notifyCallHungup:(NSString *)callID usrExtDat:(NSString *)usrExtDat
{
    MLog(@"callID:%@", callID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCallHungup:usrExtDat:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCallHungup:callID usrExtDat:usrExtDat];
        }
    });
}

// 透明通道
// 发送信令结果
- (void)sendCmdRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sendId:%@ sdkErr:%u cookie:%@", sendId, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:sendCmdRlst:sdkErr:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self sendCmdRlst:sendId sdkErr:sdkErr cookie:cookie];
        }
    });
}

// 发送数据结果
- (void)sendBufferRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sendId:%@ sdkErr:%u cookie:%@", sendId, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:sendBufferRlst:sdkErr:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self sendBufferRlst:sendId sdkErr:sdkErr cookie:cookie];
        }
    });
}

// 发送文件结果
- (void)sendFileRlst:(NSString *)sendId fileName:(NSString *)fileName sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sendId:%@ fileName:%@ sdkErr:%u cookie:%@", sendId, fileName, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:sendFileRlst:fileName:sdkErr:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self sendFileRlst:sendId fileName:fileName sdkErr:sdkErr cookie:cookie];
        }
    });
}

// 发送数据进度(文件和数据共用)
- (void)sendProgress:(NSString *)sendId sendedLen:(int)sendedLen totalLen:(int)totalLen cookie:(NSString *)cookie
{
    MLog(@"sendId:%@ sendedLen:%d totalLen:%d cookie:%@", sendId, sendedLen, totalLen, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:sendProgress:sendedLen:totalLen:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self sendProgress:sendId sendedLen:sendedLen totalLen:totalLen cookie:cookie];
        }
    });
}

// 取消发送数据结果
- (void)cancelSendRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie
{
    MLog(@"sendId:%@ sdkErr:%u cookie:%@", sendId, sdkErr, cookie);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:cancelSendRlst:sdkErr:cookie:)]) {
            [_videoMgrDelegate videoMgrCallBack:self cancelSendRlst:sendId sdkErr:sdkErr cookie:cookie];
        }
    });
}

// 接收信令
- (void)notifyCmdData:(NSString *)sourceUserId data:(NSString *)data
{
    MLog(@"sourceUserId:%@ data.lenght:%@", sourceUserId, @(data.length));
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCmdData:data:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCmdData:sourceUserId data:data];
        }
    });
}

// 接收数据
- (void)notifyBufferData:(NSString *)sourceUserId data:(NSString *)data
{
    MLog(@"sourceUserId:%@ data.lenght:%@", sourceUserId, @(data.length));
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyBufferData:data:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyBufferData:sourceUserId data:data];
        }
    });
}

// 接收文件
- (void)notifyFileData:(NSString *)sourceUserId tmpFile:(NSString *)tmpFile orgFileName:(NSString *)orgFileName
{
    MLog(@"sourceUserId:%@ tmpFile:%@ orgFileName:%@", sourceUserId, tmpFile, orgFileName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyFileData:tmpFile:orgFileName:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyFileData:sourceUserId tmpFile:tmpFile orgFileName:orgFileName];
        }
    });
}

// 取消数据发送
- (void)notifyCancelSend:(NSString *)sendId
{
    MLog(@"sendId:%@", sendId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_videoMgrDelegate respondsToSelector:@selector(videoMgrCallBack:notifyCancelSend:)]) {
            [_videoMgrDelegate videoMgrCallBack:self notifyCancelSend:sendId];
        }
    });
}

- (void)callMorePartyRslt:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    
}


- (void)cancelCallMorePartyRslt:(NSString *)inviteID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    
}


- (void)getUserStatusRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userStatus:(NSArray<UserStatus *> *)userStatus cookie:(NSString *)cookie {
    
}


- (void)notifyCallMorePartyStatus:(NSString *)inviteID status:(CR_INVITE_STATUS)status {
    
}


- (void)notifyUserStatus:(UserStatus *)uStatus {
    
}


- (void)startStatusPushRsp:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    
}


- (void)stopStatusPushRsp:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    
}

@end
