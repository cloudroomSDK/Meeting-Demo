let RTCSDK;
const penType = {
	1: 'Pencil',
}
Component({
	/**
	 * 组件的属性列表
	 */
	properties: {
		config: Object,
	},

	/**
	 * 组件的初始数据
	 */
	data: {
		showCanvas: false,
	},

	lifetimes: {
		created: function () {
			RTCSDK = wx.RTCSDK || getApp().globalData.RTCSDK;
			//查询标注状态的结果
			RTCSDK.GetScreenShareInfoRslt.callback = (code, data) => {
				if (code !== 0 || data.state !== 3 || this.data.showCanvas) return;
				this.setData({
					showCanvas: true
				}, () => {
					this._canvasInit();
				});
			}
			//查询标注数据的结果
			RTCSDK.GetAllMarkDataRslt.callback = (code, data) => {
				const markDataList = [];
				for (let i = 0; i < data.length; i++) {
					markDataList.push(this.parseData(data[i]));
				}
				this.markDataList = markDataList;
			}
			//通知开始了标注
			RTCSDK.NotifyStartMarked.callback = () => {
				if (this.data.showCanvas) return;
				this.markDataList = [];
				this.setData({
					showCanvas: true
				}, () => {
					this._canvasInit();
				});
			}
			//通知停止了标注
            RTCSDK.NotifyStopMarked.callback = () => {
				this.bgImage = null;
                this.markDataList = null;
				clearTimeout(this.referLoyoutTimerId);
                clearTimeout(this.getScreenTimerId);
                if (!this.ctx) return;

				this.clearCanvas(this.ctx);
				this.setData({
					showCanvas: false
				});
			}
			//通知有标注数据
			RTCSDK.NotifyMarkData.callback = (data) => {
				if (!this.markDataList || !this.ctx) return;
				const parseData = this.parseData(data);
				this.markDataList.push(parseData);
				this.drawData(parseData);
			}
			//通知清空标注数据
			RTCSDK.NotifyClearAllMarks.callback = () => {
				if (!this.markDataList || !this.ctx) return;
                this.markDataList = [];
				this._resetDraw();
			}
			RTCSDK.Publish.addEventListener('sendScreenInfo', this.setScreenInfo.bind(this));
		},
		attached() {},
		ready: function () {
			RTCSDK.GetScreenShareInfo(); //查询标注状态
		},
		detached: function () {
			RTCSDK.GetScreenShareInfoRslt.callback = null;
			RTCSDK.GetAllMarkDataRslt.callback = null;
			RTCSDK.NotifyStartMarked.callback = null;
			RTCSDK.NotifyStopMarked.callback = null;
			RTCSDK.NotifyMarkData.callback = null;
			clearTimeout(this.referLoyoutTimerId);
			clearTimeout(this.getScreenTimerId);
			RTCSDK.Publish.removeAllEvent('sendScreenInfo');
		},
	},
	/**
	 * 组件的方法列表
	 */
	methods: {
		_canvasInit() {
			const query = this.createSelectorQuery()
			query.select('#canvas')
				.fields({
					node: true,
					size: true
				})
				.exec((res) => {
					if (!this.properties.config) return;
					const canvas = res[0].node;
					this.ctx = canvas.getContext('2d');

					this.boxWidth = res[0].width; //盒子宽度
					this.boxHeight = res[0].height; //盒子高度

					this._boxWidth = res[0].width; //盒子宽度
					this._boxHeight = res[0].height; //盒子高度

					this.canvas = canvas;
					const dpr = wx.getSystemInfoSync().pixelRatio;
					this.dpr = dpr;

					canvas.width = this.boxWidth * dpr;
					canvas.height = this.boxHeight * dpr;
					this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

					this.vertical = this.properties.config.orientation !== 'horizontal'; //方向

					RTCSDK.Publish.emitEventListener('getScreenInfo');
					RTCSDK.GetAllMarkData('v4');
				});
			this.referLoyoutTimerId = setInterval(() => {
				const query = this.createSelectorQuery()
				query.select('#canvas')
					.fields({
						node: true,
						size: true
					})
					.exec((res) => {
						if (!this.properties.config || !this.ctx) return;
						if (this._boxWidth === res[0].width && this._boxHeight === res[0].height) return;

						const canvas = res[0].node;

						this.boxWidth = res[0].width; //盒子宽度
						this.boxHeight = res[0].height; //盒子高度

						this._boxWidth = res[0].width; //盒子宽度
						this._boxHeight = res[0].height; //盒子高度

						const dpr = wx.getSystemInfoSync().pixelRatio;
						this.dpr = dpr;
						canvas.width = res[0].width * dpr;
						canvas.height = res[0].height * dpr;
						if (!this.vertical) {
							[this.boxWidth, this.boxHeight] = [this.boxHeight, this.boxWidth]
						}
						this.clearCanvas(this.ctx);
						this.drawBgImage(this.ctx);
					})

			}, 300);
		},
		_resetDraw() {
			const ctx = this.ctx;
			this.clearCanvas(ctx);
			this.drawBgImage(ctx);
		},
		clearCanvas(ctx) {
			ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
			ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
		},
		drawBgImage(ctx) {
			if (!this.bgImage) return;
			let scale;
			const bgInfo = this.bgImage.info;
			if (this.boxWidth / this.boxHeight < bgInfo.videoWidth / bgInfo.videoHeight) {
				scale = this.boxWidth / bgInfo.videoWidth; //视频缩放比例
			} else {
				scale = this.boxHeight / bgInfo.videoHeight; //视频缩放比例
			}

			if (RTCSDK.systemInfo.platform === 'ios') {
				let a, b;
				if (bgInfo.width / bgInfo.height > this.boxWidth / this.boxHeight) {
					const w = bgInfo.height * scale; //图片的高度
					a = this.boxHeight - w; //黑边占的高度
					b = 0;
				} else {
					const w = bgInfo.width * scale; //图片的高度
					a = 0;
					b = this.boxWidth - w; //黑边占的高度
				}

				if (!this.vertical) {
					ctx.translate(this.boxHeight, 0);
					ctx.rotate(90 * Math.PI / 180);
				}
				ctx.drawImage(this.bgImage, b / 2, a / 2, this.boxWidth - b, this.boxHeight - a);
				ctx.translate(b / 2, a / 2);
				ctx.scale(scale, scale);
			} else if (RTCSDK.systemInfo.platform === 'android') {
				const imgHeight = this.vertical ? this.bgImage.position[3] : this.bgImage.position[2];
				const imgWidth = this.vertical ? this.bgImage.position[2] : this.bgImage.position[3];
				let cx, cy, cw, ch;
				if (this.boxWidth / this.boxHeight < imgWidth / imgHeight) {
					const boxImageHeight = imgHeight / imgWidth * this.boxWidth;
					const b = this.boxHeight - boxImageHeight;
					cx = 0;
					cy = b / 2;
					cw = this.boxWidth;
					ch = boxImageHeight;
				} else {
					const b = this.boxWidth - imgWidth * this.boxHeight / imgHeight; //黑边的计算
					cx = b / 2;
					cy = 0;
					cw = this.boxWidth - b;
					ch = this.boxHeight;
				}

				if (!this.vertical) {
					[cx, cy, cw, ch] = [cy, cx, ch, cw];
				}
				const [ix, iy, iw, ih] = this.bgImage.position;
				if (this.vertical) {
					ctx.drawImage(this.bgImage, ix, iy, iw, ih, cx, cy, cw, ch);
					ctx.translate(cx, cy);
					ctx.scale(scale, scale);
				} else {
					ctx.drawImage(this.bgImage, ix, iy, iw, ih, cx, cy, cw, ch);
					ctx.translate(this.boxHeight, 0);
					ctx.rotate(90 * Math.PI / 180);
					ctx.translate(cy, cx);
					ctx.scale(scale, scale);
				}
			}
			this.drawAllPen();
		},
		setScreenInfo(info) {
			if (info.code !== 0) {
				this.getScreenTimerId = setTimeout(() => {
					RTCSDK.Publish.emitEventListener('getScreenInfo');
				}, 500);
				return;
			}
			const image = this.canvas.createImage();
			image.src = info.tempImagePath;
			if (!this.vertical) {
				[this.boxWidth, this.boxHeight] = [this.boxHeight, this.boxWidth]
			}

			image.onload = () => {
				if (RTCSDK.systemInfo.platform === 'android') {
					let position = [];

					if (this.vertical) {
						if (info.width / info.height < info.videoWidth / info.videoHeight) {
							const h = info.width * info.videoHeight / info.videoWidth;
							const b = info.height - h;
							position[0] = 0; //x
							position[1] = b / 2; //y
							position[2] = info.width; //w
							position[3] = h; //h
						} else {
							const width = info.videoWidth * info.height / info.videoHeight;
							const b = info.width - width;
							position[0] = b / 2; //x
							position[1] = 0; //y
							position[2] = width; //w
							position[3] = info.height; //h
						}
					} else {
						[info.width, info.height] = [info.height, info.width];
						if (info.width / info.height < info.videoWidth / info.videoHeight) {
							const height = info.videoHeight / (info.videoWidth / info.width);
							const b = info.height - height;
							position[0] = b / 2; //x
							position[1] = 0; //y
							position[2] = height; //w
							position[3] = info.width; //h
						} else {
							const b = info.width - info.videoWidth;
							position[0] = 0; //x
							position[1] = b / 2; //y
							position[2] = info.height; //w
							position[3] = info.videoWidth; //h
						}
					}
					image.position = position;
				}
				image.info = info;
				this.bgImage = image;
				this.clearCanvas(this.ctx);
				this.drawBgImage(this.ctx);
			}
		},
		//解析数据
		parseData(data) {
			//颜色的序列化规则 #2555dd -> 0xdd<<16|0x55<<8|0x25 -> 14505253
			const parse = {};
			parse.type = data.type;
			parse.markId = data.markid;

			const penData = data.mousePosSeq;
			const red = penData[3].toString(16);
			const green = penData[2].toString(16);
			const blue = penData[1].toString(16);

			parse.color = '#' + (Array(2).join(0) + red).slice(-2) + (Array(2).join(0) + green).slice(-2) + (Array(2).join(0) + blue).slice(-2);

			let i = 4;
			parse.width = penData[i++] << 8 | penData[i++];
			parse.size = penData[i++] << 8 | penData[i++];

			const arr = [];
			const dataView = new DataView(penData.buffer);

			while (i < penData.length) {
				let obj = {};
				obj.x = dataView.getInt16(i);
				i += 2;
				obj.y = dataView.getInt16(i);
				i += 2;
				arr.push(obj);
			}
			parse.data = arr;
			return parse;
		},
		drawAllPen() {
			const markDataList = this.markDataList;
			for (let i = 0; i < markDataList.length; i++) {
				this.drawData(markDataList[i])
			}
		},
		//选择画笔类型绘制
		drawData(parseData) {
			if (!penType[parseData.type]) return console.crlog('[CRScreenMarkV4]画笔未定义,类型: ' + parseData.type);
			this['draw' + penType[parseData.type]](parseData);
		},

		drawPencil(parseData) {
			const ctx = this.ctx;
			const data = parseData.data;
			ctx.strokeStyle = parseData.color;
			ctx.lineWidth = parseData.width;
			ctx.beginPath();
			ctx.moveTo(data[0].x, data[0].y);
			for (let i = 3; i < data.length; i++) {
				ctx.lineTo(data[i].x, data[i].y);
			}
			ctx.stroke();
		},
	}
})
