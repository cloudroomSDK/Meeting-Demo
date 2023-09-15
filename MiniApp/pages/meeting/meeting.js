const app = getApp();
const RTCSDK = require('../../utils/RTCSDK/RTC_Miniapp_SDK.min.js');;
const Tools = require('../../utils/tools');
const sdkErrDesc = require('../../utils/sdkErrDesc');

let record_size_arr = [ // 云端录制推荐分辨率
	[640, 360, 400],
	[964, 480, 600],
	[1280, 720, 1200]
];



Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		sdkver: RTCSDK.sdkver, // sdk版本号
		enableCam: false, // 摄像头是否关闭
		curMeetId: null,
		// userID: null, // 登录用户id
		// nickname: null, // 登录用户昵称
		pusherDebug: false, //推流组件调试开关
		playerDebug: false, //播放组件调试开关
		isBeautify: false, // 是否开启美颜功能
		showSetting: false,	//显示设置按钮
		showChat: false,	//显示聊天框
		chatCount: 0,	//显示聊天的数量

		openVideoList: [],
	},

	// 生命周期函数--监听页面加载
	onLoad: function (options) {
		console.log('Meeting page load...');

		this.initData(); // 初始化数据
		this.enterMeetSuccessFun(); // 跳到这个页面，表示已经进入房间，执行进入房间后操作

		this.updateRecordStatue(); // 先获取云端录制状态
		this.getMediaStatue(); //获取影音录制、屏幕共享状态
	},
	// 生命周期函数--监听页面初次渲染完成
	onReady: function () {
		console.log('Meeting page ready...');

		wx.onNetworkStatusChange((res) => { // 监听网络状态变化
			console.log('========  小程序网络变化  ========')
			console.log('isConnected: ' + res.isConnected);
			console.log('networkType: ' + res.networkType);
		})
		
		this.setData({
			pusherDebug: app.globalData.pusherDebug,
			playerDebug: app.globalData.playerDebug
		})
	},
	// 生命周期函数--监听页面显示
	onShow: function () {
		console.log('Meeting page show...');
		this.setKeepScreenOn(); //设置屏幕常亮
	},
	// 生命周期函数--监听页面隐藏
	onHide: function () {
		console.log('Meeting page hide...');
		app.isHide = true;

	},
	// 生命周期函数--监听页面卸载
	onUnload: function () {
		console.log('Meeting page unload...');
		this.exitMeetFun();
	},
	// 页面相关事件处理函数--监听用户下拉动作
	onPullDownRefresh: function () {
		console.log('Meeting page PullDownRefresh...');
	},
	// 页面上拉触底事件的处理函数
	onReachBottom: function () {
		console.log('Meeting page ReachBottom...');
	},
	// 用户点击右上角分享
	onShareAppMessage: function () {
		const shareObj = {};
		if (app.globalData.serverCfg.useToken) {
			shareObj.useToken = true;
			shareObj.token = app.globalData.serverCfg.token;
		} else {
			shareObj.useToken = false;
			shareObj.AppID = app.globalData.serverCfg.AppID || app.globalData.serverCfg.defaultAppID;
			shareObj.AppSecret = app.globalData.serverCfg.AppSecret;
		}
		shareObj.server = app.globalData.serverCfg.serverAddr;
		shareObj.meetId = this.data.curMeetId;

		return {
			title: '视频会议Demo',
			path: `/pages/login/login?shareInfo=${encodeURIComponent(JSON.stringify(shareObj))}`, // 带上房间信息，分享进入直接入会
			imageUrl: '/image/shareImg.png',
			success: function (res) { }
		}
	},
	// 初始化数据
	initData() {
		// 成员信息配置，每个成员都需要配置各自对应的视频播放组件live-player。音频和视频都是live-player，音频不显示宽高，视频静音
		const openVideoList = [],
			curCamStatus = app.globalData.enterMeetOpenVideo, // 摄像头当前开关
			curMicStatus = app.globalData.enterMeetOpenMic; // 麦克风当前开关

		//推流组件默认配置,通过修改data，组件实施更新
		const RTCVideoPusher = {
			orientation: 'vertical', // vertical,horizontal,
			aspect: '3:4', // 宽高比，可选值有 3:4, 9:16
			beauty: 0, // 美颜，取值范围 0-9 ，0 表示关闭
			whiteness: 0, // 美白，取值范围 0-9 ，0 表示关闭
			devicePosition: 'front', // 前置或后置，值为front, back,此属性不支持动态修改，如需切换摄像头请调用api
			muted: !curMicStatus, //默认静音
			enableCamera: curCamStatus, //默认打开摄像头
			minBitrate: app.optionCfg.minRateRate, //	最小码率
			maxBitrate: app.optionCfg.maxRateRate, // 最大码率
			waitingImage: '/image/be_closed.jpg', // 进入后台时推流的等待画面
		}

		//视频播放组件默认配置,通过修改data，组件实施更新
		const RTCVideoPlayer = {
			orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal	
			objectFit: 'fillCrop', // 填充模式，可选值有 contain，fillCrop	
		}

		//音频播放组件默认配置,通过修改data，组件实施更新
		const RTCAudioPlayer = {
			soundMode: 'speaker', // 声音输出方式，有效值为 speaker（扬声器）、ear（听筒）
		}

		const isRecordTime = true, // 是否录制时间
			isRecordName = true, // 是否录制名称
			isRecordOneself = false, // 是否只录制自己
			userRatio = 1.777777, // 成员视频的默认比例
			isSvrRecording = false, // 是否正在云端录制中
			recordTimer = -1, // 录制计时器id
			recordNowTime = 0, // 当前录制时间
			recordBtnText = '录制', // 录制按钮的文字
			recordViewClass = 'icon', // 录制组件的class类名
			isBeautify = false, // 默认不打开美颜
			mediaLayout = false, //屏幕共享或者影音共享布局
			myUserInfo = null,
			curMeetId = app.globalData.curMeetId; // 房间信息

		this.setData({
			RTCVideoPusher,
			RTCVideoPlayer,
			RTCAudioPlayer,
			openVideoList,
			isRecordTime,
			isRecordName,
			isRecordOneself,
			userRatio,
			isSvrRecording,
			recordTimer,
			recordNowTime,
			recordBtnText,
			recordViewClass,
			isBeautify,
			mediaLayout,
			myUserInfo,
			curMeetId,
			curCamStatus,
			curMicStatus
		})
	},
	// 进入房间成功的操作
	enterMeetSuccessFun() {
		const myUserInfo = RTCSDK.GetMemberInfo(app.globalData.userInfo.UID);

		//找到房间内所有摄像头列表
		const watchableVideosList = RTCSDK.GetWatchableVideos();
		const openVideoList = [];
		
		watchableVideosList.forEach(item => {
			const memberInfo = RTCSDK.GetMemberInfo(item.userID);
			const videoConfig = {
				userId: item.userID,
				camId: item.videoID, //摄像头Id
				orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal	
				objectFit: 'fillCrop', // 填充模式，可选值有 contain，fillCrop	
				// autoPauseIfNavigate: true, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放
				// autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放
			}

			openVideoList.push({
				camKey: `${item.userID}-${item.videoID}`,
				memberInfo,
				videoConfig
			})
		});

		this.setData({
			myUserInfo,
			openVideoList, // 放到data用来渲染视频组件
		});
	},
	// 保持屏幕常亮
	setKeepScreenOn() {
		//因为live-player组件释放会导致屏幕常亮失效，所以需要每隔一段时间设置一次常亮。属于微信的bug
		clearTimeout(this.keepScreenTimerId);
		this.keepScreenTimerId = setTimeout(() => {
			wx.setKeepScreenOn({ // 屏幕保持常亮
				keepScreenOn: true
			});
			this.setKeepScreenOn();
		}, 14e3);
	},
	longpressScreen(e){
		const { key } = e.currentTarget.dataset;
		if(this.fullSceenId && this.selectComponent(`#${this.fullSceenId}`)) {
			this.selectComponent(`#${key}`).exitFullScreen();
			this.fullSceenId = null;
		} else {
			this.selectComponent(`#${key}`).fullScreen(90);
			this.fullSceenId = key;
		}
	},
	//更新屏幕共享、影音共享状态
	getMediaStatue() {
		const UID = RTCSDK.GetScreenInfo();
		UID && this.startMedia(UID, 'screen');

		RTCSDK.GetMediaInfo();

	},
	//开启影音共享或者媒体共享
	startMedia(UID, type) {
		console.log(`${UID},开启了${type == 'screen' ? '屏幕共享' : '影音共享'}`);
		Tools.showToast(`${type == 'screen' ? '屏幕共享' : '影音共享'}已开启，长按可全屏`, 3000);
		const config = {
			type,
			userId: UID,
			orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal
			objectFit: 'contain', // 填充模式，可选值有 contain，fillCrop
			// autoPauseIfNavigate: true, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放
			// autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放
		}
		
		this.setData({
			mediaLayout: true,
			mediaMemberInfo: RTCSDK.GetMemberInfo(UID),
			RTCMediaPlayer: config,
		})

		this.updateRecordLayout(); // 更新云端录制参数
	},
	//停止影音共享、媒体共享
	stopMedia(type) {
		console.log(`停止了${type == 'screen' ? '屏幕共享' : '影音共享'}`);
		this.setData({
			mediaLayout: false,
			mediaMemberInfo: null,
			RTCMediaPlayer: null,
		})

		this.updateRecordLayout(); // 更新云端录制参数
	},
	// 接收回调消息处理
	onMessage: {
		//当前页面如果收到入会回调，则是重新登录入会
		EnterMeetingRslt(code, cookie) {
			Tools.hideLoading();
			if (code === 0) {
				this.onLoad();
				this.onReady();
			} else {
				wx.reLaunch({ // 返回登录页面
					url: '/pages/login/login',
					success: function () {
						Tools.showToast('登录失败');
					}
				})
			}
		},
		//通知自己从房间中掉线
		MeetingDropped() {
			this.clearRecordTimer();
			this.setData({
				openVideoList: [],
				myUserInfo: null,
			})
		},
		// 通知有新用户进入房间
		UserEnterMeeting(UID) {

			const userInfo = RTCSDK.GetMemberInfo(UID);

			Tools.showToast(userInfo.nickname + ' 进入房间', 2000);

		},
		//打开本地麦克风失败回调
		OpenMicFailRslt(sdkErr) {
			this.permissionDeniedHandler(sdkErr);
		},
		//打开本地摄像头失败回调
		OpenVideoFailRslt(sdkErr) {
			this.permissionDeniedHandler(sdkErr);
		},
		// 通知有用户离开房间
		UserLeftMeeting(UID, leftReson) {
			if (UID !== app.globalData.userInfo.UID) { // 别人离开
				const openVideoList = this.data.openVideoList.filter(item => item.memberInfo.userID !== UID);

				this.setData({ openVideoList });

				Tools.showToast(UID + ' 离开了房间', 2000);

			} else { // 自己离开

				if (leftReson == 'kick') {
					console.log('被从房间中踢出！');

					wx.reLaunch({ // 返回登录页面
						url: '/pages/login/login',
						success: function () {
							Tools.showToast('您被踢出了房间', 2000);
						}
					})
				}
			}
		},
		//摄像头列表改变，其他端开启或关闭多摄像头进入该方法，开启需展示到页面上，关闭需要从页面中删除
		VideoDevChanged(UID, openIds) {
			this.updateMemberCamShow(UID);
		},
		// 通知某个成员摄像头状态变化
		VideoStatusChanged(userID, oldStatus, newStatus) {
			if (userID != app.globalData.userInfo.UID) {
				const index = this.data.openVideoList.findIndex(item => item && item.memberInfo.userID == userID);

				if (index > -1) {
					const key = `openVideoList[${index}].memberInfo.videoStatus`;
					this.setData({
						[key]: newStatus
					});
				}

				this.updateMemberCamShow(userID);
			} else {
				const key = `myUserInfo.videoStatus`;
				this.setData({
					[key]: newStatus
				});
			}

			if (oldStatus !== 3 && newStatus == 3) {
				Tools.showToast(RTCSDK.GetMemberInfo(userID).nickname + ' 打开了摄像头');
				if (userID == app.globalData.userInfo.UID) this.setData({
					curCamStatus: true
				});
			} else if (oldStatus == 3 && newStatus == 2) {
				Tools.showToast(RTCSDK.GetMemberInfo(userID).nickname + ' 关闭了摄像头');
				if (userID == app.globalData.userInfo.UID) this.setData({
					curCamStatus: false
				});
			}
			this.updateRecordLayout(); // 更新云端录制参数

		},

		// 通知某个成员麦克风状态变化
		AudioStatusChanged(userID, oldStatus, newStatus) {
			if (userID != app.globalData.userInfo.UID) {
				const index = this.data.openVideoList.findIndex(item => item && item.memberInfo.userID == userID);

				if (index > -1) {
					const key = `openVideoList[${index}].memberInfo.audioStatus`;
					this.setData({
						[key]: newStatus
					});
				}
			} else {
				const key = `myUserInfo.audioStatus`;
				this.setData({
					[key]: newStatus
				});
			}
			if (oldStatus !== 3 && newStatus == 3) {
				Tools.showToast(RTCSDK.GetMemberInfo(userID).nickname + ' 打开了麦克风');
				if (userID == app.globalData.userInfo.UID) this.setData({
					curMicStatus: true
				});
			} else if (oldStatus == 3 && newStatus == 2) {
				Tools.showToast(RTCSDK.GetMemberInfo(userID).nickname + ' 关闭了麦克风');
				if (userID == app.globalData.userInfo.UID) this.setData({
					curMicStatus: false
				});
			}
		},
		// 通知全体静音
		NotifyAllAudioClose(opId) {
			const userInfo = RTCSDK.GetMemberInfo(opId)
			const nickName = userInfo ? userInfo.userID : opId;
			Tools.showToast(`"${nickName}"操作了全体静音`);

			this.setData({ curMicStatus: false });
		},
		// 通知昵称被修改
		NotifyNickNameChanged(UID, oldname, newname) {
			const userIndex = this.data.openVideoList.findIndex(item => item && item.memberInfo.userID === UID);
			if (userIndex === -1) return;
			const key = `openVideoList[${userIndex}].memberInfo.nickname`;
			this.setData({
				[key]: newname
			});
		},
		// 通知开启了屏幕共享
		NotifyScreenShareStarted(UID) {
			this.startMedia(UID, 'screen');
		},
		//通知关闭了屏幕共享
		NotifyScreenShareStopped() {
			this.stopMedia('screen');
		},
		//查询影音共享的结果
		GetMediaInfoRslt(sdkErr, MediaInfoObj) {
			if (sdkErr != 0) return console.log('获取影音共享状态异常,code:' + sdkErr);
			if (MediaInfoObj.state === 2) return; //影音共享未开启
			this.startMedia(MediaInfoObj.userId, 'media');
		},
		//通知开启了影音共享
		NotifyMediaStart(UID) {
			this.startMedia(UID, 'media');
		},
		//通知影音共享暂停
		NotifyMediaPause(UID, pause) {
			console.log(`影音共享${pause ? '暂停' : '开始'}了`);
		},
		//通知关闭了影音共享
		NotifyMediaStop() {
			this.stopMedia('media');
		},
		//启动云端录制、云端直播失败通知
		CreateCloudMixerFailed(mixerID, sdkErr) {
			if (mixerID !== this.myMixerId) return;
			Tools.showToast(`启动录制失败,错误码：${sdkErr},${sdkErrDesc(sdkErr)}`);
			this.myMixerId = null;
			this.setData({
				recordViewClass: 'icon',
				isSvrRecording: false,
				recordBtnText: '录制',
			});
		},
		// 云端录制、云端直播状态变化通知
		CloudMixerStateChanged(mixerID, state, exParam, operUserID) {
			if (mixerID !== this.myMixerId) return;
			if (state == 1) {
				this.setData({
					recordNowTime: 0
				});
				Tools.showToast('云端录制启动中...', 2000);
			}
			if (state == 2) {
				clearInterval(this.data.recordTimer);
				let timerId = setInterval(() => {
					let nowTime = this.data.recordNowTime + 1;
					this.setData({
						recordNowTime: nowTime,
					});
					let second = nowTime % 60;
					let second_str = second >= 10 ? second.toString() : "0" + second;
					let minute = parseInt(nowTime / 60);
					let minute_str = minute >= 10 ? minute.toString() : "0" + minute;

					this.setData({
						recordViewClass: 'icon icon-recording',
						recordBtnText: minute_str + ':' + second_str,
					});

				}, 1000);
				Tools.showToast('正在云端录制...', 2000);

				this.setData({
					isSvrRecording: true,
					recordTimer: timerId
				});

			} else if (state == 0) {
				if (this.data.recordTimer != -1) {
					clearInterval(this.data.recordTimer);
					// timerId = -1;
					this.setData({
						recordTimer: -1
					});
				}
				this.setData({
					recordViewClass: 'icon',
					recordBtnText: '录制',
					isSvrRecording: false
				});
				Tools.showToast('云端录制已结束', 2000);
			}
		},
		//云端录制文件、云端直播输出变化通知
		CloudMixerOutputInfoChanged(mixerID, outputInfo) {
			if (mixerID !== this.myMixerId) return;
			switch (outputInfo.state) {
				case 3:
					Tools.showToast(`录制出错！错误码：${outputInfo.errCode},${outputInfo.errDesc}`);
					this.myMixerId = null;
					break;
				case 4:
					Tools.showToast(`正在上传，${Math.ceil(outputInfo.progress)}%`);
					break;
				case 6:
					Tools.showToast(`上传失败`);
					this.myMixerId = null;
					break;
				case 7:
					Tools.showToast(`录制已完成，可在后台中查看录像文件`);
					this.myMixerId = null;
					break;

				default:
					break;
			}
		},
		// 通知房间结束
		MeetingStopped(id) {
			wx.showModal({
				title: '提示',
				content: '当前房间已结束，请重新进入正在进行中的房间或创建新的房间！',
				showCancel: false,
				success: res => {
					if (res.confirm) {
						this.exitMeeting();
					}
				}
			})
		},
		//收到邀请通知
		NotifyInviteIn(inviteID, inviterUsrID, usrExtDat) {
			RTCSDK.RejectInvite(inviteID, 'Meeting');
		},
		//需要更新邀请列表
		updateInviteList() {
			this.selectComponent('#optionSetting').updateInviteList();
		},
		//通知收到IM聊天消息
		NotifyMeetingCustomMsg(UID, json) {
			const data = JSON.parse(json);
			if (data.CmdType !== 'IM') return; //非IM消息

			const formUserInfo = RTCSDK.GetMemberInfo(UID);
			if (!this.data.showChat && UID !== app.globalData.userInfo.UID) {
				this.setData({ chatCount: ++this.data.chatCount })
			}
			this.selectComponent('#chat').notifyMsg(UID, formUserInfo.nickname, data);
		},
		SendMeetingCustomMsgRslt(sdkErr, cookie) {
			if (sdkErr !== 0) {
				const desc = `消息发送失败,错误码：${sdkErr},${sdkErrDesc(sdkErr)}`
				console.log(desc);
				Tools.showToast(desc);
				return;
			}
			console.log('广播消息发送成功');
		}
	},
	//更新某个用户的视频窗口数量
	updateMemberCamShow(UID) {
		//查询可观看摄像头列表
		const memberOpenIds = RTCSDK.GetWatchableVideos(UID).map(item => item.videoID);

		let openVideoList = this.data.openVideoList;
		//已经展示在页面中的摄像头数组
		const memberOpenedCamArr = openVideoList.filter(item => item.memberInfo.userID === UID).map(item => item.videoConfig.camId);

		const deleteCamArr = Tools.difference(memberOpenedCamArr, memberOpenIds); //需要在展示中删除的摄像头列表
		const addCamArr = Tools.difference(memberOpenIds, memberOpenedCamArr); //需要在展示中添加的摄像头列表

		//删除页面中的摄像头
		deleteCamArr.forEach(item => {
			openVideoList = openVideoList.filter(item2 => !(item2.memberInfo.userID === UID && item === item2.videoConfig.camId));
		})

		const memberInfo = RTCSDK.GetMemberInfo(UID);
		//添加摄像头渲染
		addCamArr.forEach(item => {
			const videoConfig = {
				userId: UID,
				camId: item, //摄像头Id
				orientation: 'vertical', // 画面方向，可选值有 vertical，horizontal	
				objectFit: 'fillCrop', // 填充模式，可选值有 contain，fillCrop	
				// autoPauseIfNavigate: true, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放
				// autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放
			}
			openVideoList.push({
				camKey: `${UID}-${item}`,
				memberInfo,
				videoConfig
			})
		})
		this.setData({
			openVideoList
		})

		this.updateRecordLayout(); // 更新云端录制参数
	},
	// 点击挂断按钮
	exitMeeting() {
		// 退出房间
		this.exitMeetFun();

		console.log('navigateBack from meeting page..')
		wx.navigateBack({ // 返回登录页面
			delta: 1
		})
	},
	// 离开房间的操作
	exitMeetFun() {
		this.stopRecord(); //停止云端录制
		clearTimeout(this.keepScreenTimerId);
		this.clearRecordTimer(); //清除云端录制计时器

		app.globalData.inviteList = [];

		RTCSDK.ExitMeeting(); // sdk离开房间接口
	},
	// -------------------- 摄像头、麦克风操作 ---------------------
	// 开关摄像头
	closeVideo(e) {
		if (this.data.curCamStatus === true) {
			RTCSDK.CloseVideo(app.globalData.userInfo.UID); // 关闭摄像头
			const videoStatus = RTCSDK.GetMemberInfo(app.globalData.userInfo.UID).videoStatus;
			this.setData({
				'myUserInfo.videoStatus': videoStatus,
				curCamStatus: false,
			})

		} else {
			RTCSDK.OpenVideo(app.globalData.userInfo.UID); // 打开摄像头
			const videoStatus = RTCSDK.GetMemberInfo(app.globalData.userInfo.UID).videoStatus;
			this.setData({
				'myUserInfo.videoStatus': videoStatus,
				curCamStatus: true,
			})
		}
		this.updateRecordLayout(); // 更新云端录制参数
	},
	// 切换前后摄像头
	toggleCam(e) {
		RTCSDK.SetDefaultVideo(app.globalData.userInfo.UID, ''); // 切换前后摄像头
	},
	//点击选项按钮
	toggleOption() {
		this.setData({ showSetting: !this.data.showSetting });
	},
	//切换聊天框
	toggleChat() {
		const count = this.data.showChat ? 0 : this.data.chatCount;
		this.setData({
			showChat: !this.data.showChat,
			chatCount: count
		});
	},
	// 开关麦克风
	closeMic(e) {
		if (this.data.curMicStatus) {
			RTCSDK.CloseMic(app.globalData.userInfo.UID); // 关闭麦克风
			const audioStatus = RTCSDK.GetMemberInfo(app.globalData.userInfo.UID).audioStatus;
			this.setData({
				'myUserInfo.audioStatus': audioStatus,
				curMicStatus: false
			})
		} else {
			RTCSDK.OpenMic(app.globalData.userInfo.UID); // 打开麦克风
			const audioStatus = RTCSDK.GetMemberInfo(app.globalData.userInfo.UID).audioStatus;
			this.setData({
				'myUserInfo.audioStatus': audioStatus,
				curMicStatus: true
			})
		}
	},
	// 开关美颜功能
	toggleBeautify(e) {
		if (this.data.isBeautify) { // 关闭美颜

			this.setData({
				isBeautify: false,
				'RTCVideoPusher.beauty': 0,
				'RTCVideoPusher.whiteness': 0
			})

		} else { // 打开美颜

			this.setData({
				isBeautify: true,
				'RTCVideoPusher.beauty': 5,
				'RTCVideoPusher.whiteness': 5
			})
		}
	},
	//摄像头麦克风权限不足处理
	permissionDeniedHandler(sdkErr) {
		if (this.permissionDeniedTimer) return;
		this.permissionDeniedTimer = setTimeout(() => {
			this.permissionDeniedTimer = null;
			const resetVideo = () => {
				const myInfo = this.data.myUserInfo;
				//重新渲染videoPusher组件，让组件重新加载摄像头麦克风权限
				this.setData({
					myUserInfo: null
				}, () => {
					this.setData({
						myUserInfo: myInfo
					});
				})
			}
			wx.showModal({
				title: '权限不足',
				content: '可以前往设置中打开权限,设置完成后请重新打开小程序',
				confirmText: '去设置',
				showCancel: true,
				success: (res) => {
					if (res.confirm) {
						if (sdkErr === 704 || sdkErr === 702) {
							wx.openAppAuthorizeSetting ? wx.openAppAuthorizeSetting() : Tools.showToast(sdkErrDesc(sdkErr))
						} else if (sdkErr === 705 || sdkErr === 703) {
							wx.openSetting({
								success: resetVideo
							});
						}
					}
				}
			})
		}, 200);
	},
	// ------------------- 云端录制 -------------------
	// 开始/停止云端录制
	toggleCloudRecord(e) {
		/* 3种状态：
			正在录制中 this.myMixerId && this.data.isSvrRecording
			已完成录制，后台正在处理	this.myMixerId && !this.data.isSvrRecording
			未开始录制 !this.myMixerId && !this.data.isSvrRecording 
		*/

		// 录制中
		if (this.myMixerId) {
			// 正在录制
			if (this.data.isSvrRecording) {
				this.stopRecord(); //结束录制
				if (this.data.recordTimer != -1) {
					clearInterval(this.data.recordTimer);
				}
				this.setData({
					recordBtnText: '录制',
					recordViewClass: 'icon',
					isSvrRecording: false,
					recordTimer: -1,
				})
			} else {
				// 已完成录制，后台正在处理
				Tools.showToast('操作太频繁，请稍后再试');
			}
		} else {
			// 未开始录制

			const date = new Date();
			let year = date.getFullYear(),
				month = date.getMonth() + 1,
				day = date.getDate(),
				hour = date.getHours(),
				minute = date.getMinutes(),
				second = date.getSeconds();

			month = month < 10 ? ('0' + month) : month;
			day = day < 10 ? ('0' + day) : day;
			hour = hour < 10 ? ('0' + hour) : hour;
			minute = minute < 10 ? ('0' + minute) : minute;
			second = second < 10 ? ('0' + second) : second;

			const svrPathName = `/${year}-${month}-${day}/${year}-${month}-${day}_${hour}-${minute}-${second}_WX_${this.data.curMeetId}`;
			const [W, H, B] = record_size_arr[app.optionCfg.definition];
			const { frameRate, recordMP3 } = app.optionCfg;

			const mixerCfg = {
				mode: 0,
				videoFileCfg: {
					svrPathName: `${svrPathName}.mp4`,
					vWidth: W,
					vHeight: H,
					vBps: B * 1000,
					vFps: frameRate,
					layoutConfig: this.createRecordLayout()
				},
				audioFileCfg: recordMP3 ? {
					svrPathName: `${svrPathName}.mp3`
				} : undefined
			}

			if (this.data.recordTimer != -1) {
				clearInterval(this.data.recordTimer);
			}
			this.setData({
				isSvrRecording: true,
				recordBtnText: '启动中',
				recordViewClass: '',
				recordTimer: -1,
			})

			this.myMixerId = RTCSDK.CreateCloudMixer(mixerCfg);
		}
	},
	//创建录制内容数组
	createRecordLayout() {
		let size = record_size_arr[app.optionCfg.definition];
		const [W, H] = size; //视频宽度

		let x, y; //每行、每列视频个数
		let width, height; //每个成员视频宽度,每个成员视频高度
		let left, top; //在视频的x，y坐标存放录制内容
		let AllMembers = []; //用户数组存放

		const layout = [];

		//如果是共享中，不录制摄像头
		if (this.data.mediaLayout) {
			layout.push({
				type: this.data.RTCMediaPlayer.type === 'screen' ? 5 : 3, // 录影音共享或屏幕共享
				left: 0,
				top: 0,
				width: W,
				height: H,
				keepAspectRatio: 1
			});
		} else {
			//不是共享状态，则录制摄像头

			//先将自己的摄像头添加进数组
			if (this.data.curCamStatus) {
				AllMembers.push({
					memberInfo: RTCSDK.GetMemberInfo(app.globalData.userInfo.UID),
					videoConfig: {
						camId: -1
					}
				})
			}
			//将所有可见的摄像头加入数组
			if (!this.data.isRecordOneself) {
				let openVideoList = this.data.openVideoList;
				openVideoList.forEach(item => {
					AllMembers.push(item);
				})
			}

			//大于9人时，只录制9人
			if (AllMembers.length > 9) {
				AllMembers.length = 9;
			}

			if (AllMembers.length <= 0) {
				x = -1;
				y = -1;

				layout.push({
					type: 10, //添加文本
					left: W / 2 - 135,
					top: H / 2 - 15,
					param: {
						"font-size": 30,
						color: '#e21918',
						text: '暂无成员开启摄像头'
					}
				});
			} else if (AllMembers.length <= 1) {
				x = 1;
				y = 1;
			} else if (AllMembers.length <= 2) {
				x = 2;
				y = 1;
			} else if (AllMembers.length <= 4) {
				x = 2;
				y = 2;
			} else if (AllMembers.length > 4) {
				x = 3;
				y = 3;
			}

			width = parseInt(W / x);
			height = parseInt(H / y); //计算每个摄像头占用的宽高

			AllMembers.forEach((item, i) => {
				let startTop = (H - height * y) / 2;
				let tmpTop = y == 1 ? 0 : parseInt(i / x);
				top = startTop + tmpTop * height;
				left = (i % x) * width;

				layout.push({
					type: 0, // 录视频
					left,
					top,
					width,
					height,
					param: {
						camid: item.memberInfo.userID + "." + item.videoConfig.camId
					},
					keepAspectRatio: 1
				});

				if (this.data.isRecordName) {
					layout.push({
						type: 10, //添加文本
						left: left + 40,
						top: top + 10,
						param: {
							"font-size": 14,
							color: '#e21918',
							text: item.memberInfo.nickname
						}
					})
				}
			})
		}

		//录制时间
		if (this.data.isRecordTime) {
			layout.push({
				type: 10, // 加时间戳
				left: W - 250,
				top: H - 30,
				keepAspectRatio: 1,
				param: {
					"font-size": 14,
					text: "%timestamp%"
				}
			});
		}

		return layout;
	},
	//更新录制参数
	updateRecordLayout() {
		if (!this.data.isSvrRecording) return;

		const cfg = {
			videoFileCfg: {
				layoutConfig: this.createRecordLayout()
			}
		}

		RTCSDK.UpdateCloudMixerContent(this.myMixerId, cfg);
	},
	//清除计时器，退出房间时调用
	clearRecordTimer() {
		clearInterval(this.data.recordTimer);
		// $record.removeClass('icon-recording').addClass('icon');
		this.setData({
			recordViewClass: 'icon'
		})
	},
	//停止云端录制
	stopRecord() {
		if (this.data.isSvrRecording && this.myMixerId) {
			this.setData({ isSvrRecording: false })
			RTCSDK.DestroyCloudMixer(this.myMixerId);
		}
	},
	//更新云端录制状态
	updateRecordStatue() {
		let status = 0
		//     0, 没有创建
		//     1, 正在开启
		//     2, 正在运行
		//     4, 正在结束
		RTCSDK.GetAllCloudMixerInfo().some(item => {
			if (item.owner === app.globalData.userInfo.UID) {
				this.myMixerId = item.ID;
				status = item.state;
				return true
			}
		});

		switch (status) {
			case 0:
				this.setData({
					isSvrRecording: false,
					recordBtnText: '录制',
				});
				break;
			case 2:
				this.setData({
					isSvrRecording: true,
					recordBtnText: '录制中...',
					recordViewClass: 'icon icon-recording',
				})
				break;
			default:
				this.setData({
					isSvrRecording: false,
				})
				break;
		}
	}
})