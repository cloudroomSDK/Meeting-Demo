const Tools = require('../../utils/tools')
const app = getApp()
const RTCSDK = require('../../utils/RTCSDK/RTC_Miniapp_SDK.min.js');;

Component({
	properties: {
		show: {
			type: Boolean,
			value: false
		}
	},
	data: {
		currentTab: 0,
		frameRate: app.optionCfg.frameRate,	//录制帧率
		recordMP3: app.optionCfg.recordMP3,	//同时录制MP3
		minRateRate: app.optionCfg.minRateRate, //当前设置的最小码率
		maxRateRate: app.optionCfg.maxRateRate, //当前设置的最大码率
		inviteList: app.globalData.inviteList,	//邀请列表
		inviteUID: '', //邀请人
		remoteMirror: false, //远端是否镜像
		resolutionList: [{
			name: '0',
			value: '360P',
			checked: app.optionCfg.definition == 0
		}, {
			name: '1',
			value: '480P',
			checked: app.optionCfg.definition == 1
		}, {
			name: '2',
			value: '720P',
			checked: app.optionCfg.definition == 2
		}],
		localMirrorList: [{
			value: 'auto',
			name: '前置摄像头镜像，后置摄像头不镜像',
			checked: 'true'
		}, {
			value: 'enable',
			name: '前后置摄像头均镜像'
		}, {
			value: 'disable',
			name: '前后置摄像头均不镜像'
		}],
		beautyStyleList: [{
			name: 'smooth',
			value: '光滑美颜',
			checked: true,
		}, {
			name: 'nature',
			value: '自然美颜',
		}],
		filterList: [{
			name: 'standard',
			value: '标准',
			checked: true,
		}, {
			name: 'pink',
			value: '粉嫩',
		}, {
			name: 'nostalgia',
			value: '怀旧',
		}, {
			name: 'blues',
			value: '蓝调',
		}, {
			name: 'romantic',
			value: '浪漫',
		}, {
			name: 'cool',
			value: '清凉',
		}, {
			name: 'fresher',
			value: '清新',
		}, {
			name: 'solor',
			value: '日系',
		}, {
			name: 'aestheticism',
			value: '唯美',
		}, {
			name: 'whitening',
			value: '美白',
		}, {
			name: 'cerisered',
			value: '樱红',
		}],
	},
	methods: {
		hide() {
			this.triggerEvent('toggle')
		},
		//远端镜像选项改变
		changeRemoteMirror(e) {
			const value = e.detail.value;

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.remoteMirror': value });
		},
		//本地镜像选项改变
		checkLocalMirror(e) {
			const value = e.detail.value

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.localMirror': value });
		},
		// 滑动切换tab
		bindChange(e) {
			this.setData({ currentTab: e.detail.current });
		},
		// 点击tab切换
		swichNav(e) {
			if (this.data.currentTab !== e.target.dataset.current) {
				this.setData({ currentTab: e.target.dataset.current })
			}
		},
		//最小码率改变
		minRateChange(e) {
			const rate = e.detail.value;
			this.setData({ minRateRate: rate });

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.minBitrate': rate });

			app.optionCfg.minRateRate = rate;
			this.savaCfgLocal();
			Tools.showToast('设置成功');
		},
		//最大码率改变
		maxRateChange(e) {
			const rate = e.detail.value;
			this.setData({ maxRateRate: rate });

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.maxBitrate': rate });

			app.optionCfg.maxRateRate = rate;
			this.savaCfgLocal();
			Tools.showToast('设置成功');
		},

		//帧率改变
		frameRateChange(e) {
			const rate = e.detail.value;
			app.optionCfg.frameRate = rate;
			this.savaCfgLocal();

			Tools.showToast('设置成功,重新录制生效');
		},
		//分辨率改变
		resolutionChange(e) {
			const ratio = +e.detail.value;
			app.optionCfg.definition = ratio;
			this.savaCfgLocal();
			Tools.showToast('设置成功,重新录制生效');
		},
		//生成MP3文件状态改变
		recordMP3Change(e) {
			const value = e.detail.value;
			app.optionCfg.recordMP3 = value;
			this.savaCfgLocal();
			Tools.showToast('设置成功,重新录制生效');
		},
		//美颜类型改变
		beautyStyleChange(e) {
			const value = e.detail.value;

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.beautyStyle': value });
		},
		//美颜类型改变
		fliterChange(e) {
			const value = e.detail.value;

			const pageAll = getCurrentPages();
			const lastPage = pageAll[pageAll.length - 1];
			lastPage.setData({ 'RTCVideoPusher.filter': value });
		},
		savaCfgLocal() {
			wx.setStorage({
				key: "CR_OptionCfg",
				data: JSON.stringify(app.optionCfg)
			})
		},
		//邀请人被改变
		inviteUIDChange(e) {
			this.setData({ inviteUID: e.detail.value });
		},
		//取消邀请
		cancelInvite(e) {
			const inviteId = e.target.dataset.inviteid;
			RTCSDK.CancelInvite(inviteId);
		},
		//邀请按钮
		inviteBtn() {
			const inviteUID = this.data.inviteUID;
			if (!inviteUID) return Tools.showToast('请输入邀请者的UID');
			const curMeetId = app.globalData.curMeetId;
			const usrExtDat = {
				meeting: {
					ID: curMeetId
				}
			}
			const inviteID = RTCSDK.Invite(inviteUID, JSON.stringify(usrExtDat));
			app.globalData.inviteList.unshift({
				inviteID,
				inviteUID,
				desc: '发送邀请中...'
			})
			this.updateInviteList();
		},
		updateInviteList() {
			this.setData({ inviteList: app.globalData.inviteList });
		}
	},
})
