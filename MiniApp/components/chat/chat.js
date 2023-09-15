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
		msgInput: '', // 消息输入框内容
		msgList: [], // IM消息列表
	},
	lifetimes: {
		attached() {
			this.setData({
				myUID: app.globalData.userInfo.UID,
				msgInput: '',
				toView: 'msg-' + (this.data.msgList.length - 1),
			});
		},
		detached() {
			// 在组件实例被从页面节点树移除时执行
		},
	},
	methods: {
		hide() {
			this.triggerEvent('toggle')
		},
		//通知有聊天消息
		notifyMsg(UID, nickName, data) {
			const text = data.IMMsg;

			const IMMsgObj = {
				fromUserId: UID,
				nickname: nickName || UID,
				text
			}
			const length = this.data.msgList.length;
			const key = `msgList[${length}]`

			this.setData({ [key]: IMMsgObj, }, () => {
				this.setData({ toView: 'msg-' + (length), })
			});
		},
		// 输入文字
		imMsgInput(e) {
			this.setData({ msgInput: e.detail.value })
		},
		// 发送im消息的方法
		sendMsgFun(value) {
			if (!value) {
				Tools.showToast('请输入消息内容！');
				return;
			}
			const data = {
				CmdType: "IM",
				IMMsg: value
			};
	
			RTCSDK.SendMeetingCustomMsg(JSON.stringify(data)); // 发送IM消息接口
			this.setData({ msgInput: '' })
		},
	
		// 点击键盘上的发送按钮发送消息
		sendClick(e) {
			this.sendMsgFun(e.detail.value);
		},
	
		// 点击发送键发送消息
		sendMsg(e) {
			this.sendMsgFun(this.data.msgInput);
		},
	}
})
