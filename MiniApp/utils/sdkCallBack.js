const RTCSDK = require('./RTCSDK/RTC_Miniapp_SDK.min.js');;
const Tools = require('./tools');
const sdkErrDesc = require('./sdkErrDesc');

//批量注册所有页面的方法
const allPagesNotifyArr = [
	'MeetingStopped',
	'UserEnterMeeting',
	'UserLeftMeeting',
	'VideoStatusChanged',
	'AudioStatusChanged',
	'NotifyAllAudioClose',
	'CreateCloudMixerFailed',
	'CloudMixerStateChanged',
	'CloudMixerOutputInfoChanged',
	'NotifyScreenShareStarted',
	'NotifyScreenShareStopped',
	'NotifyMediaStart',
	'NotifyMediaPause',
	'NotifyMediaStop',
	'MeetingStopped',
	'SendMeetingCustomMsgRslt',
	'VideoDevChanged',
	'NotifyMeetingCustomMsg',
	'AcceptInviteSuccess',
	'AcceptInviteFail',
	'GetMediaInfoRslt',
	'NotifyNickNameChanged'
];

//批量注册只给当前页面的方法
const singlePageNotifyArr = ['EnterMeetingRslt', 'CreateMeetingSuccess', 'CreateMeetingFail', 'OpenMicFailRslt', 'OpenVideoFailRslt'];

allPagesNotifyArr.forEach(item => {
	RTCSDK[item].callback = (...arg) => {
		console.log(item, arg);
		Tools.sendAllPagesMessage(item, arg);
	}
});

singlePageNotifyArr.forEach(item => {
	RTCSDK[item].callback = (...arg) => {
		console.log(item, arg);
		Tools.sendPageMessage(item, arg);
	}
});

//登录成功
RTCSDK.LoginSuccess.callback = (UID, data) => {
	console.log('LoginSuccess', [UID, data]);
	const app = getApp();
	Tools.showToast(`登录成功`, 1000);
	app.globalData.userInfo.UID = UID;
	app.globalData.SDKLoginStatus = 2;
	Tools.sendPageMessage('LoginSuccess', [UID, data]);
}

//登录失败
RTCSDK.LoginFail.callback = (sdkErr, cookie) => {
	console.log('LoginFail', [sdkErr, cookie]);
	const app = getApp();
	const desc = `登录失败,错误码：${sdkErr},${sdkErrDesc(sdkErr)}`
	app.globalData.SDKLoginStatus = 0;
	Tools.showToast(desc);
	Tools.sendPageMessage('LoginFail', [sdkErr, cookie]);
}

//登录掉线
RTCSDK.LineOff.callback = (sdkErr) => {
	const app = getApp();
	app.globalData.SDKLoginStatus = 0;
	console.log('LineOff', [sdkErr]);
	Tools.showToast(`登录掉线,错误码: ${sdkErr},${sdkErrDesc(sdkErr)}`, 1500);
	Tools.sendPageMessage('LineOff', [sdkErr]);
}

//token即将失效通知
RTCSDK.NotifyTokenWillExpire.callback = () => {
	console.log('token即将失效');
	Tools.showToast('token即将失效', 3000);
}

//收到透明通道消息
RTCSDK.NotifyCmdData.callback = (UID, data) => {
	Tools.showToast(`收到来自${UID}的消息: ${data}`);
}

//收到透明通道消息
RTCSDK.NotifyBufferData.callback = (UID, data) => {
	Tools.showToast(`收到大数据块消息，来自${UID}的消息，消息长度: ${data.length}`);
}
//房间掉线通知
RTCSDK.MeetingDropped.callback = (code) => {
	wx.showModal({
		title: '提示',
		content: '房间掉线，是否重新进入房间?',
		success(res) {
			if (res.confirm) {
				Tools.showLoading('请稍后', false);
				const app = getApp();
				const meetingId = app.globalData.curMeetId,
					UID = app.globalData.userInfo.UID,
					nickName = app.globalData.userInfo.nickName;

				RTCSDK.EnterMeeting(meetingId, '', UID, nickName, {
					meetingId: meetingId
				})
			} else if (res.cancel) {
				wx.reLaunch({ // 返回登录页面
					url: '/pages/login/login'
				})
			}
		}
	});
	Tools.sendAllPagesMessage('MeetingDropped', [code]);
}

//邀请发送成功的通知
RTCSDK.NotifyInviteIn.callback = function (inviteID, inviterUsrID, usrExtDat) {
	console.log('NotifyInviteIn', arguments);
	Tools.sendPageMessage('NotifyInviteIn', [inviteID, inviterUsrID, usrExtDat]);
}
//邀请发送成功的通知
RTCSDK.InviteSuccess.callback = function (inviteID, cookie) {
	console.log('InviteSuccess', arguments);
	const app = getApp();
	const inviteInfo = app.globalData.inviteList.find(item => inviteID === item.inviteID);
	if (inviteInfo) {
		inviteInfo.desc = '发送邀请成功，等待对方答应中';
		Tools.sendPageMessage('updateInviteList');
	}
}
//邀请发送失败的通知
RTCSDK.InviteFail.callback = function (inviteID, sdkErr, cookie) {
	console.log('InviteFail', arguments);
	const app = getApp();
	const inviteInfo = app.globalData.inviteList.find(item => inviteID === item.inviteID);
	if (inviteInfo) {
		inviteInfo.desc = sdkErrDesc(sdkErr);
		Tools.sendPageMessage('updateInviteList');
	}
}
// 通知对方接受了邀请
RTCSDK.NotifyInviteAccepted.callback = function (inviteID, usrExtDat) {
	console.log('NotifyInviteAccepted', arguments);
	const app = getApp();
	const inviteInfo = app.globalData.inviteList.find(item => inviteID === item.inviteID);
	if (inviteInfo) {
		inviteInfo.desc = '邀请被对方接受';
		Tools.sendPageMessage('updateInviteList');
	}
}
// 通知对方拒绝了邀请
RTCSDK.NotifyInviteRejected.callback = function (inviteID, reason, usrExtDat) {
	console.log('NotifyInviteAccepted', arguments);
	const app = getApp();
	const inviteInfo = app.globalData.inviteList.find(item => inviteID === item.inviteID);
	if (inviteInfo) {
		inviteInfo.desc = reason === 0 ? (usrExtDat === 'Meeting' ? '邀请被拒绝,对方在房间中' : '邀请被对方主动拒绝') : sdkErrDesc(reason);
		Tools.sendPageMessage('updateInviteList');
	}
}

//拒绝邀请成功的通知
RTCSDK.RejectInviteSuccess.callback = function (inviteID, cookie) {
	console.log('RejectInviteSuccess', arguments);
	console.log('拒绝邀请成功');
}
//拒绝邀请失败的通知
RTCSDK.RejectInviteFail.callback = function (inviteID, sdkErr, cookie) {
	console.log('RejectInviteFail', arguments);
	const desc = `拒绝邀请失败。${sdkErr},${sdkErrDesc(sdkErr)}`;
	console.log(desc);
	Tools.showToast(desc);
}
//通知邀请被取消
RTCSDK.NotifyInviteCanceled.callback = function (inviteID, reason, usrExtDat) {
	console.log('inviteID', arguments);
	console.log(`邀请被取消`);
	Tools.sendPageMessage('NotifyInviteCanceled', [inviteID, reason, usrExtDat]);
}

//取消邀请成功的通知
RTCSDK.CancelInviteSuccess.callback = function (inviteID, cookie) {
	console.log('CancelInviteSuccess', arguments);
	const app = getApp();
	const inviteInfo = app.globalData.inviteList.find(item => inviteID === item.inviteID);
	if (inviteInfo) {
		inviteInfo.desc = '已取消';
		Tools.sendPageMessage('updateInviteList');
	}
}
//取消邀请失败的通知
RTCSDK.CancelInviteFail.callback = function (inviteID, sdkErr, cookie) {
	console.log('CancelInviteFail', arguments);
	const desc = `取消邀请失败。${sdkErr},${sdkErrDesc(sdkErr)}`;
	console.log(desc);
	Tools.showToast(desc);
}