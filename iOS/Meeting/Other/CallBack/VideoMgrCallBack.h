//
//  VideoMgrCallBack.h
//  VideoCall
//
//  Created by king on 2017/6/7.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoMgrCallBack;

@protocol VideoMgrDelegate <NSObject>

@optional
// 登录响应
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback loginSuccess:(NSString *)usrID cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 掉线通知
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr;
// 客户端免打扰状态响应
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback setDNDStatusSuccess:(NSObject *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback setDNDStatusFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 创建房间
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 获取房间列表
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback getMeetingListSuccess:(NSArray <MeetInfo *> *)meetList cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback getMeetingListFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;

// 邀请他人参会响应
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback callSuccess:(NSString *)callID cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback callFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 接受他人邀请响应
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback acceptCallSuccess:(NSString *)callID cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback acceptCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 拒绝他人邀请响应
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback rejectCallSuccess:(NSString *)callID cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback rejectCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 拆除呼叫
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback hangupCallSuccess:(NSString *)callID cookie:(NSString *)cookie;
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback hangupCallFail:(NSString *)callID errCode:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 服务端通知被邀请
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCallIn:(NSString *)callID meetInfo:(MeetInfo *)meetInfo callerID:(NSString *)callerID usrExtDat:(NSString *)usrExtDat;
// 服务端通知房间邀请被接受
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCallAccepted:(NSString *)callID meetInfo:(MeetInfo *)meetInfo usrExtDat:(NSString *)usrExtDat;
// 服务端通知邀请被拒绝
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCallRejected:(NSString *)callID reason:(CRVIDEOSDK_ERR_DEF)reason usrExtDat:(NSString *)usrExtDat;
// 服务端通知呼叫被结束
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCallHungup:(NSString *)callID usrExtDat:(NSString *)usrExtDat;
// 透明通道
// 发送信令结果
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback sendCmdRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送数据结果
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback sendBufferRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送文件结果
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback sendFileRlst:(NSString *)sendId fileName:(NSString *)fileName sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 发送数据进度(文件和数据共用)
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback sendProgress:(NSString *)sendId sendedLen:(int)sendedLen totalLen:(int)totalLen cookie:(NSString *)cookie;
// 取消发送数据结果
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback cancelSendRlst:(NSString *)sendId sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 接收信令
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCmdData:(NSString *)sourceUserId data:(NSString *)data;
// 接收数据
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyBufferData:(NSString *)sourceUserId data:(NSString *)data;
// 接收文件
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyFileData:(NSString *)sourceUserId tmpFile:(NSString *)tmpFile orgFileName:(NSString *)orgFileName;
// 取消数据发送
- (void)videoMgrCallBack:(VideoMgrCallBack *)callback notifyCancelSend:(NSString *)sendId;
@end

@interface VideoMgrCallBack : NSObject <CloudroomVideoMgrCallBack>

@property (nonatomic, weak) id <VideoMgrDelegate> videoMgrDelegate;

@end
