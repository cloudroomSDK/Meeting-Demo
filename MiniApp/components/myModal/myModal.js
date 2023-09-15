Component({

	/**
	 * 组件的初始数据
	 */
	data: {
		isShow: false,
		modalTitle: null,
		modalMsg: null,
	},

	/**
	 * 组件的方法列表
	 */
	methods: {
		//隐藏弹框
		hideModal() {
			this.setData({
				isShow: false
			})
		},
		//展示弹框
		showModal(config) {
			this.confirmFn = config.confirm;
			this.cancelFn = config.cancel;
			this.setData({
				modalMsg: config.content,
				isShow: true
			})
		},
		_cancelEvent() {
			//触发取消回调
			this.hideModal();
			this.cancelFn && this.cancelFn();
		},
		_confirmEvent() {
			//触发成功回调
			this.hideModal();
			this.confirmFn && this.confirmFn();
		}
	}
})