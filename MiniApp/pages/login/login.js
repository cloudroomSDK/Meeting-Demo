const sdkErrDesc = require('../../utils/sdkErrDesc');
const Tools = require('../../utils/tools');
const app = getApp();
const RTCSDK = require('../../utils/RTCSDK/RTC_Miniapp_SDK.min.js');;

let lastMeetId = wx.getStorageSync('CR_MeetingID') || '';

Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		SDKlogin: false,
	},
	/**
	 * 生命周期函数--监听页面加载
	 */
	onLoad: function (options) {
		this.setData({
			demoVer: app.globalData.ver,
			sdkVer: app.globalData.sdkVer,
		})

		if (options && options.shareInfo) { //分享入会
			const shareInfo = JSON.parse(decodeURIComponent(options.shareInfo));
			app.shareLogin(shareInfo);
		}
	},
	/**
	 * 生命周期函数--监听页面初次渲染完成
	 */
	onReady: function () {
		this.myModal = this.selectComponent("#modal");
	},
	/**
	 * 生命周期函数--监听页面显示
	 */
	onShow: function () {
		const SDKLoginStatus = app.globalData.SDKLoginStatus;
		this.setData({
			SDKlogin: SDKLoginStatus === 2 ? true : false,
			meetingId: lastMeetId
		})
		if (SDKLoginStatus === 0) {
			if (app.shareJoin) return;
			app.SDKLogin();
		}
	},
	/**
	 * 生命周期函数--监听页面隐藏
	 */
	onHide: function () {
		clearTimeout(app.globalData.loginTermId);
	},
	/**
	 * 生命周期函数--监听页面卸载
	 */
	onUnload: function () {},
	/**
	 * 页面相关事件处理函数--监听用户下拉动作
	 */
	onPullDownRefresh: function () {},
	/**
	 * 页面上拉触底事件的处理函数
	 */
	onReachBottom: function () {},
	/**
	 * 用户点击右上角分享
	 */
	onShareAppMessage: function () {
		return Tools.defaultShare();
	},

	// 点击设置按钮
	loginSetShow(e) {
		wx.navigateTo({
			url: '../setting/setting',
			success: function (res) {
				console.log(res)
			},
			fail: function (res) {
				console.log(res)
			}
		})

	},

	// 输入房间号事件
	meetingIDInput(e) {
		this.setData({
			meetingId: e.detail.value
		});
		// app.meetingInfo.meetingID = e.detail.value;
	},

	// 输入房间号获取焦点
	meetIdFocus(e) {
		this.setData({
			meetingId: ''
		})
	},

	// 点击进入房间按钮
	enterMeet(e) {
		const meetingId = String(this.data.meetingId);
		console.log('房间号：' + meetingId);
		if (meetingId.length !== 8) {
			Tools.showToast('请输入8位房间号！');
		} else if (meetingId.replace(/[^0-9]/ig, "").length !== 8) {
			Tools.showToast('请输入正确的房间号！');
		} else {
			Tools.showLoading('正在进入房间');
			const UID = app.globalData.userInfo.UID,
				nickName = app.globalData.userInfo.nickName;
			RTCSDK.EnterMeeting2(meetingId, UID, nickName, {
				meetingId: meetingId
			}); // sdk进入房间接口
		}
	},
	// 点击创建房间按钮
	creatMeeting(e) {
		Tools.showLoading('正在创建房间');
		RTCSDK.CreateMeeting("wxMeetingDemo"); // sdk创建房间接口
	},

	onMessage: {
		//小程序最小化
		AppOnHide() {
			this.setData({
				SDKlogin: false
			});
		},
		//登录成功
		LoginSuccess(UID, cookie) {
			this.setData({
				SDKlogin: true,
				UID
			})
			if (cookie && cookie.share) {
				Tools.showLoading('进入房间')
				lastMeetId = cookie.shareInfo.meetId;
				const nickName = app.globalData.userInfo.nickName;
				RTCSDK.EnterMeeting2(lastMeetId, UID, nickName, {
					meetingId: lastMeetId
				}); // sdk进入房间接口
			}
		},
		//登录失败
		LoginFail(sdkErr, cookie) {
			app.globalData.loginTermId = setTimeout(() => {
				app.SDKLogin();
			}, 10000);
			this.setData({
				SDKlogin: false
			})
		},
		//进入房间的响应
		EnterMeetingRslt(sdkErr, cookie) {
			app.shareJoin = false;
			Tools.hideLoading();
			if (sdkErr === 0) {
				console.log('进入房间成功... meetingID: ' + cookie.meetingId);

				wx.setStorage({
					key: 'CR_MeetingID',
					data: cookie.meetingId,
				});
				lastMeetId = cookie.meetingId;
				this.setData({
					meetingId: cookie.meetingId
				})

				app.globalData.curMeetId = cookie.meetingId; //存放房间ID
				app.globalData.messageList = []; //清空消息列表

				wx.navigateTo({
					url: '/pages/meeting/meeting',
				});
			} else {
				const desc = `登录失败,错误码：${sdkErr},${sdkErrDesc(sdkErr)}`
				console.log(desc);
				Tools.showToast(desc);
			}
		},
		//创建房间成功
		CreateMeetingSuccess(meetObj, cookie) {
			const meetingId = meetObj.ID;
			Tools.showLoading('正在进入房间');
			const UID = app.globalData.userInfo.UID,
				nickName = app.globalData.userInfo.nickName;
			RTCSDK.EnterMeeting2(meetingId, UID, nickName, {
				meetingId: meetingId
			}); // sdk进入房间接口
		},
		//创建房间失败
		CreateMeetingFail(sdkErr, cookie) {
			Tools.hideLoading();
			Tools.showToast(`创建房间失败,错误码：${sdkErr},${sdkErrDesc(sdkErr)}`);
		},
		LineOff() {
			this.onMessage.LoginFail.apply(this);
		},
		//通知有邀请
		NotifyInviteIn(inviteID, inviterUsrID, usrExtDat) {
			console.log(`收到邀请通知inviteID: ${inviteID}`);
			const meetId = JSON.parse(usrExtDat).meeting.ID;
			this.myModal.showModal({
				title: '邀请通知',
				content: `${inviterUsrID}正在邀请你……`,
				confirm() {
					Tools.showLoading('接受邀请');
					RTCSDK.AcceptInvite(inviteID, '', meetId);
				},
				cancel() {
					RTCSDK.RejectInvite(inviteID);
				}
			})
		},
		//接受邀请成功的通知
		AcceptInviteSuccess(inviteID, cookie) {
			Tools.showLoading('正在进入房间');
			const meetingId = cookie,
				UID = app.globalData.userInfo.UID,
				nickName = app.globalData.userInfo.nickName;

			RTCSDK.EnterMeeting2(meetingId, UID, nickName, {
				meetingId: meetingId
			});
		},
		//接受邀请失败的通知
		AcceptInviteFail(inviteID, sdkErr, cookie) {
			const desc = `接受邀请失败。错误码：${sdkErr}, ${sdkErrDesc(sdkErr)}`
			Tools.showToast(desc);
			console.log(desc);
		},
		//通知邀请被取消
		NotifyInviteCanceled(inviteID, reason, usrExtDat) {
			this.myModal.hideModal();
			Tools.showToast(reason === 0 ? '对方已取消邀请' : sdkErrDesc(reason));
		}
	}
})