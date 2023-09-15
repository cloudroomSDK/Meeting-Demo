const app = getApp();
const Tools = require('../../utils/tools');
const RTCSDK = require('../../utils/RTCSDK/RTC_Miniapp_SDK.min.js');;

Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		serverAddr: '',
		useToken: '',
		AppID: '',
		AppSecret: '',
		token: '',
		enterMeetOpenVideo: true,
		enterMeetOpenMic: true,
		pusherDebug: false,
		playerDebug: false,
		wxDebug: app.systemInfo.enableDebug,
	},

	/**
	 * 生命周期函数--监听页面加载
	 */
	onLoad: function (options) {
		this.setData({
			serverAddr: app.globalData.serverCfg.serverAddr,
			useToken: app.globalData.serverCfg.useToken,
			AppID: app.globalData.serverCfg.AppID,
			AppSecret: app.globalData.serverCfg.AppSecret,
			token: app.globalData.serverCfg.token,
			userAuthCode: app.globalData.serverCfg.userAuthCode,
			enterMeetOpenVideo: app.globalData.enterMeetOpenVideo,
			enterMeetOpenMic: app.globalData.enterMeetOpenMic,
			pusherDebug: app.globalData.pusherDebug,
			playerDebug: app.globalData.playerDebug,
		});
	},

	/**
	 * 用户点击右上角分享
	 */
	onShareAppMessage: function () {
		return Tools.defaultShare();
	},


	// 输入服务器地址
	svrAddrInput(e) {
		this.setData({
			serverAddr: e.detail.value
		});

	},
	// 输入用户名
	AppIDInput(e) {
		this.setData({
			AppID: e.detail.value
		})
	},
	// 输入密码
	pswdInput(e) {
		this.setData({
			AppSecret: e.detail.value
		});
	},
	// 输入token
	tokenInput(e) {
		this.setData({
			token: e.detail.value
		});
	},
	// 输入token
	userAuthCodeInput(e) {
		this.setData({
			userAuthCode: e.detail.value
		});
	},
	// 点击保存按钮
	loginSetSave(e) {
		let configChange = false;
		if (app.globalData.serverCfg.serverAddr !== this.data.serverAddr) {
			wx.setStorage({
				key: 'CR_ServerAddr',
				data: this.data.serverAddr,
			});
			app.globalData.serverCfg.serverAddr = this.data.serverAddr;
			configChange = true;
		}
		if (app.globalData.serverCfg.useToken !== this.data.useToken) {
			wx.setStorage({
				key: 'CR_UseToken',
				data: this.data.useToken,
			});
			app.globalData.serverCfg.useToken = this.data.useToken;
			configChange = true;
		}
		if (app.globalData.serverCfg.AppID !== this.data.AppID) {
			wx.setStorage({
				key: 'CR_AppID',
				data: this.data.AppID,
			});
			app.globalData.serverCfg.AppID = this.data.AppID;
			configChange = true;
		}
		if (app.globalData.serverCfg.AppSecret !== this.data.AppSecret) {
			wx.setStorage({
				key: 'CR_AppSecret',
				data: this.data.AppSecret,
			});
			app.globalData.serverCfg.AppSecret = this.data.AppSecret;
			configChange = true;
		}
		if (app.globalData.serverCfg.token !== this.data.token) {
			wx.setStorage({
				key: 'CR_Token',
				data: this.data.token,
			});
			app.globalData.serverCfg.token = this.data.token;
			configChange = true;
		}
		if (app.globalData.serverCfg.userAuthCode !== this.data.userAuthCode) {
			wx.setStorage({
				key: 'userAuthCode',
				data: this.data.userAuthCode,
			});
			app.globalData.serverCfg.userAuthCode = this.data.userAuthCode;
			configChange = true;
		}
		
		if (app.globalData.enterMeetOpenVideo !== this.data.enterMeetOpenVideo) {
			app.globalData.enterMeetOpenVideo = this.data.enterMeetOpenVideo;
		}
		if (app.globalData.enterMeetOpenMic !== this.data.enterMeetOpenMic) {
			app.globalData.enterMeetOpenMic = this.data.enterMeetOpenMic;
		}
		if (app.globalData.pusherDebug !== this.data.pusherDebug) {
			app.globalData.pusherDebug = this.data.pusherDebug;
		}
		if (app.globalData.playerDebug !== this.data.playerDebug) {
			app.globalData.playerDebug = this.data.playerDebug;
		}

		//如果登录了就注销
		if (configChange) {
			RTCSDK.Logout();
			app.globalData.SDKLoginStatus = 0;
		}

		wx.navigateBack({
			delta: 1
		});

	},
	// 点击恢复默认按钮
	resetLoginCfg(e) {
		this.setData({
			serverAddr: 'sdk.cloudroom.com',
			AppID: '',
			AppSecret: '123456',
			userAuthCode: '',
			useToken: false,
			enterMeetOpenVideo: true,
			enterMeetOpenMic: true,
			pusherDebug: false,
			playerDebug: false,
		});
	},
	useTokenSwitch(e) {
		this.setData({
			useToken: e.detail.value
		})
	},
	pusherDebugSwitch(e) {
		this.setData({pusherDebug: e.detail.value});
	},

	playerDebugSwitch(e) {
		this.setData({playerDebug: e.detail.value});
	},

	enterMeetOpenVideoSwitch(e) {
		this.setData({enterMeetOpenVideo: e.detail.value});
	},
	enterMeetOpenMicSwitch(e) {
		this.setData({enterMeetOpenMic: e.detail.value});
	},
	wxDebugSwitch(e) {
		wx.setEnableDebug({ enableDebug: e.detail.value })
	}
});