//
//  VideoMeetingCallBack.h
//  VideoCall
//
//  Created by king on 2017/6/7.
//  Copyright © 2017年 CloudRoom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoMeetingCallBack;

@protocol VideoMeetingDelegate <NSObject>

@optional
// 入会成功(入会失败，将自动发起releaseCall）
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code;
// user进入了会话
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback userEnterMeeting:(NSString *)userID;
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback userLeftMeeting:(NSString *)userID;
// 创建房间
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback createMeetingSuccess:(int)meetID password:(NSString *)password cookie:(NSString *)cookie;
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 结束房间的结果
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback stopMeetingRslt:(CRVIDEOSDK_ERR_DEF)code;
// 房间被结束了
- (void)videoMeetingCallBackMeetingStopped:(VideoMeetingCallBack *)callback;
// 房间掉线
- (void)videoMeetingCallBackMeetingDropped:(VideoMeetingCallBack *)callback;
// 最新网络评分0~10(10分为最佳网络)
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback netStateChanged:(int)level;
// 麦声音强度更新(level取值0~10)
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback micEnergyUpdate:(NSString *)userID oldLevel:(int)oldLevel newLevel:(int)newLevel;
// 本地音频设备有变化
- (void)videoMeetingCallBackAudioDevChanged:(VideoMeetingCallBack *)callback;
// 音频设备状态变化
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback audioStatusChanged:(NSString *)userID oldStatus:(AUDIO_STATUS)oldStatus newStatus:(AUDIO_STATUS)newStatus;
// 视频设备状态变化
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback videoStatusChanged:(NSString *)userID oldStatus:(VIDEO_STATUS)oldStatus newStatus:(VIDEO_STATUS)newStatus;
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback openVideoRslt:(NSString *)devID success:(BOOL)bSuccess;
// 成员有新的视频图像数据到来(通过GetVideoImg获取）
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyVideoData:(UsrVideoId *)userID frameTime:(long)frameTime;
// 本地视频设备有变化
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback videoDevChanged:(NSString *)userID;
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback defVideoChanged:(NSString *)userID videoID:(short)videoID;
// 屏幕共享操作通知
- (void)videoMeetingCallBackNotifyScreenShareStarted:(VideoMeetingCallBack *)callback;
- (void)videoMeetingCallBackNotifyScreenShareStopped:(VideoMeetingCallBack *)callback;
// 屏幕共享数据更新,用户收到该回调消息后应该调用getShareScreenDecodeImg获取最新的共享数据
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyScreenShareData:(NSString *)userID changedRect:(CGRect)changedRect frameSize:(CGSize)size;
// IM消息发送结果
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback sendIMmsgRlst:(NSString *)taskID sdkErr:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie;
// 通知收到文本消息
// FIXME:SDK更新接口导致IM回调崩溃 modified by king 20170905
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyIMmsg:(NSString *)romUserID text:(NSString *)text sendTime:(int)sendTime;
// 影音开始通知
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyMediaStart:(NSString *)userid;
// 影音停止播放的通知
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyMediaStop:(NSString *)userid reason:(MEDIA_STOP_REASON)reason;
// 影音暂停播放的通知
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyMediaPause:(NSString *)userid bPause:(BOOL)bPause;
// 视频帧数据已解好
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyMemberMediaData:(NSString *)userid curPos:(int)curPos;
// 视频墙分屏模式回调
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyVideoWallMode:(int)wallMode;

// 屏幕共享标注开始回调
- (void)videoMeetingCallBackNotifyScreenMarkStarted:(VideoMeetingCallBack *)callback;
// 屏幕共享标注停止回调
- (void)videoMeetingCallBackNotifyScreenMarkStopped:(VideoMeetingCallBack *)callback;
// 屏幕共享是否允许他人标注回调
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback enableOtherMark:(BOOL)enable;
// 屏幕共享标注回调
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback sendMarkData:(MarkData *)markData;
// 屏幕共享所有标注回调
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback sendAllMarkData:(NSArray<MarkData *> *)markDatas;
// 清除所有屏幕共享标注回调
- (void)videoMeetingCallBackClearAllMarks:(VideoMeetingCallBack *)callback;
// 通知之前已经创建好的白板
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyInitBoards:(NSArray<SubPageInfo *> *)boards;
// 通知之前已经创建好的白板上的图元数据
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyInitBoardPageDat:(SubPage *)boardID boardPageNo:(int)boardPageNo bkImgID:(NSString *)bkImgID elements:(NSString *)elements operatorID:(NSString *)operatorID;
// 通知创建子功能页白板
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyCreateBoard:(SubPageInfo *)board operatorID:(NSString *)operatorID;
// 通知关闭白板
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyCloseBoard:(SubPage *)boardID operatorID:(NSString *)operatorID;
// 通知添加图元信息
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyAddBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID;
// 通知修改图元信息
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyModifyBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo element:(NSString *)element operatorID:(NSString *)operatorID;
// 通知删除图元
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyDelBoardElement:(SubPage *)boardID boardPageNo:(int)boardPageNo elementIDs:(NSArray<NSString *> *)elementIDs operatorID:(NSString *)operatorID;
// 通知设置鼠标热点消息
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyMouseHotSpot:(SubPage *)boardID boardPageNo:(int)boardPageNo x:(int)x y:(int)y operatorID:(NSString *)operatorID;

//修改昵称
- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback setNickNameRsp:(CRVIDEOSDK_ERR_DEF)sdkErr userid:(NSString*)userid newName:(NSString*)newName;

- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyNickNameChanged:(NSString*)userid oldName:(NSString*)oldName newName:(NSString*)newName;


- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback listNetDiskDocFileRslt:(NSString*)dir err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(NetDiskDocDir*)rslt;

- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback getNetDiskDocFilePageInfoRslt:(NSString*)svrPathFileName err:(CRVIDEOSDK_ERR_DEF)sdkErr rslt:(GetDocPageInfoRslt*)rslt;

- (void)videoMeetingCallBack:(VideoMeetingCallBack *)callback notifyNetDiskDocFileTrsfProgress:(NSString*)svrPathFileName finished:(int)finished;
@end

@interface VideoMeetingCallBack : NSObject  <CloudroomVideoMeetingCallBack>

@property (nonatomic, weak) id <VideoMeetingDelegate> videoMeetingDelegate;

@end
