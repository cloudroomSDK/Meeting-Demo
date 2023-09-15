module.exports = {
	//生成随机数字
	randomNumstr(length) {
		if (typeof (length) != "number") {
			length = 4;
		}
		var numStr = "";
		for (var i = 0; i < length; i++) {
			numStr += Math.floor(Math.random() * 10)
		}
		return numStr;
	},
	//比较数组中的差异
	difference(a, b) {
		const s = new Set(b);
		return a.filter(x => !s.has(x));
	},
	// 弹出提示
	showToast(text, time, ismask) {
		// 提示文字，持续时间，是否显示遮罩
		wx.showToast({
			title: text || '',
			icon: 'none',
			duration: time || 2000,
			mask: ismask || false,
		});
	},
	//隐藏提示
	hideToast() {
		wx.hideToast()
	},
	// 弹出等待层
	showLoading(text, mask) {
		wx.showLoading({
			title: text,
			mask: mask == undefined ? true : mask
		});
	},
	// 隐藏等待层
	hideLoading() {
		wx.hideLoading();
	},
	//给所有页面发消息
	sendAllPagesMessage(event, arg) {
		getCurrentPages().forEach(item => {
			try {
				item.onMessage && item.onMessage[event] && item.onMessage[event].apply(item, arg);
			} catch (error) {
				console.error(error);
			}
		});
	},
	//给当前页发消息
	sendPageMessage(event, arg) {
		try {
			const allPages = getCurrentPages();
			const curPage = allPages[allPages.length - 1];
			curPage.onMessage && curPage.onMessage[event] && curPage.onMessage[event].apply(curPage, arg);
		} catch (error) {
			console.log(error);
		}
	},
	// 默认分享页
	defaultShare() {
		return {
			title: '视频会议Demo',
			path: '/pages/login/login', // 带上房间信息，分享进入直接入会
			imageUrl: '/image/shareImg.png',
			success: function (res) {}
		}
	},
}