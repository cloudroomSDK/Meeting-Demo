const RTCSDK = require('./utils/RTCSDK/RTC_Miniapp_SDK.min.js');
// const RTCSDK = require('./utils/RTCSDK/crsdk/sdkApi');
const SDKErrDesc = require('./utils/sdkErrDesc');
const Tools = require('./utils/tools');

const md5 = RTCSDK.MD5;

App({
	allMembers: [], // 房间内所有成员信息
	isFullScreen: false, // 是否已全屏
	isHide: false, // 是否已隐藏
	optionCfg: null, //云端录制默认配置

	globalData: {
		ver: '1.6.1', // demo版本
		sdkVer: RTCSDK.sdkver, // SDK版本
		curMeetId: null, // 当前房间
		enterMeetOpenVideo: true, // 入会打开摄像头
		enterMeetOpenMic: true, // 入会打开麦克风
		pusherDebug: false, // 是否开启推流组件的调试
		playerDebug: false, // 是否开启视频播放组件的调试
		SDKInitStatus: false, //SDK初始化状态
		SDKLoginStatus: 0, //SDK登录状态, 0未登录 1登录中 2已登录
		appHide: false, //app在后台
		userInfo: {}, // 用户个人信息
		serverCfg: {}, // 服务器和账号配置
		loginTermId: null, //自动登录计时器
		messageList: null, //IM消息列表
		inviteList: [], //邀请用户列表
		notifyInvite: [], //通知邀请列表
	},

	// 设置默认配置信息
	initDefaultCfg() {
		const optionCfg = wx.getStorageSync("CR_OptionCfg");
		this.optionCfg = optionCfg ? JSON.parse(optionCfg) : {
			frameRate: 12, //录制帧率
			recordMP3: false, //同时录制MP3
			definition: 1, //录制分辨率 0:360p ,1:480p ,2:720p
			minRateRate: 200, //推流最大码率
			maxRateRate: 800, //推流最小码率
		};

		// 设置服务器和账号信息
		let serverCfg = {};
		serverCfg.useToken = wx.getStorageSync("CR_UseToken") || false; //1,账号密码鉴权 2,动态令牌鉴权
		serverCfg.serverAddr = wx.getStorageSync("CR_ServerAddr") || 'sdk.cloudroom.com';
		serverCfg.token = wx.getStorageSync("CR_Token") || '';
		serverCfg.AppID = wx.getStorageSync("CR_AppID") || '';
		serverCfg.defaultAppID = 'demo@cloudroom.com'; //登录账号为空时，使用此默认账号
		serverCfg.AppSecret = wx.getStorageSync("CR_AppSecret") || '123456';
		serverCfg.userAuthCode = wx.getStorageSync("userAuthCode") || '';
		this.globalData.serverCfg = serverCfg;

		// 设置用户个人信息
		this.globalData.userInfo = {
			nickname: null,
			userID: null,
		}
	},

	onLaunch: function (e) {
		console.log('app ----onLaunch');
		console.log(e);
		this.checkUpdate(); //小程序更新检测

		if (e.query.shareInfo) this.shareJoin = true;
		require('./utils/sdkCallBack'); // 初始化SDK回调通知
		this.systemInfo = wx.getSystemInfoSync();
		console.log('系统信息：', this.systemInfo);
		this.initDefaultCfg(); // 设置默认的配置信息
		this.SDKInit(); //SDK初始化
	},

	onShow: function () {
		console.log('app ----onShow');
		Tools.sendAllPagesMessage('AppOnHide');
		this.globalData.appHide = false;
		if (this.globalData.SDKLoginStatus === 0 && !this.shareJoin) {
			this.shareJoin = false;
			this.SDKLogin();
		}
	},
	onHide: function () {
		this.globalData.appHide = true;
		console.log('app ---- hide');
		clearTimeout(this.globalData.loginTermId); //清除自动登录计时器
	},
	// SDK初始化
	SDKInit() {
		RTCSDK.EnableLog2File(true, true); // 设置是否上报日志/是否开启控制台打印

		// 初始化SDK
		const status = RTCSDK.Init();

		if (!status) {
			this.globalData.SDKInitStatus = true;
		} else {
			this.globalData.SDKInitStatus = false;
			Tools.showToast(`初始化失败,错误码：${status} ,${SDKErrDesc(status)}`);
		}
	},
	// SDK登录
	SDKLogin() {
		if (this.globalData.appHide) {
			console.log('app在后台，暂不登录');
			return;
		}
		clearTimeout(this.globalData.loginTermId);

		let nickName, UID;
		//如果有UID就使用上次的UID登录
		if (this.globalData.userInfo.UID) {
			UID = this.globalData.userInfo.UID;
			nickName = this.globalData.userInfo.nickName;
		} else {
			const randNum = Tools.randomNumstr(5);
			UID = `wx_${randNum}`;
			nickName = UID;
			this.globalData.userInfo.nickName = nickName;
			this.globalData.userInfo.UID = UID;
		}

		// 设置服务器地址
		RTCSDK.SetServerAddr(this.globalData.serverCfg.serverAddr);

		this.globalData.SDKLoginStatus = 1; //改变登录状态

		// 判断登录方式，传统账号密码登录或者令牌登录
		const useToken = this.globalData.serverCfg.useToken;
		const userAuthCode = this.globalData.serverCfg.userAuthCode;
		if (useToken) {
			//token模式鉴权登录，推荐使用
			const token = this.globalData.serverCfg.token;
			RTCSDK.LoginByToken(token, nickName, UID, userAuthCode, {
				share: false
			});
		} else {
			//APPID账号密码登录模式
			const AppID = this.globalData.serverCfg.AppID || this.globalData.serverCfg.defaultAppID;
			const AppSecret = this.globalData.serverCfg.AppSecret;
			RTCSDK.Login(AppID, md5(AppSecret), nickName, UID, userAuthCode, {
				share: false
			});
		}
	},
	//分享入会
	shareLogin(shareInfo) {
		Tools.showLoading('正在登录');
		this.shareJoin = false;

		const nickName = this.globalData.userInfo.nickName || 'wx' + Tools.randomNumstr(5),
			UID = this.globalData.userInfo.UID || Tools.randomNumstr(9);

		this.globalData.userInfo.nickName = nickName;
		this.globalData.userInfo.UID = UID;

		// 设置服务器地址
		RTCSDK.SetServerAddr(shareInfo.server);

		this.globalData.SDKLoginStatus = 1; //改变登录状态

		// 判断登录方式，传统账号密码登录或者令牌登录
		const useToken = shareInfo.useToken;
		const userAuthCode = shareInfo.userAuthCode;
		if (useToken) {
			//token模式鉴权登录，推荐使用
			const token = shareInfo.token;
			RTCSDK.LoginByToken(token, nickName, UID, userAuthCode, {
				share: true,
				shareInfo
			});
		} else {
			//APPID账号密码登录模式
			const AppID = shareInfo.AppID || shareInfo.defaultAppID;
			const AppSecret = shareInfo.AppSecret;
			RTCSDK.Login(AppID, md5(AppSecret), nickName, UID, userAuthCode, {
				share: true,
				shareInfo
			});
		}
	},
	//更新检测
	checkUpdate(){
		const updateManager = wx.getUpdateManager()

		updateManager.onCheckForUpdate(function (res) {
			// 请求完新版本信息的回调
            console.log(`有新版本: ${res.hasUpdate}`)
		})
	
		updateManager.onUpdateReady(function () {
			wx.showModal({
				title: '更新提示',
				content: '新版本已经准备好，是否重启应用？',
				success: function (res) {
					if (res.confirm) {
						// 新的版本已经下载好，调用 applyUpdate 应用新版本并重启
						updateManager.applyUpdate()
					}
				}
			})
		})
	}
})