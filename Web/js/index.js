layui.use(['form', 'layer', 'laytpl', 'element'], function () {
  // 初始化layui模块，注册相关事件监听
  window.layuiForm = layui.form;
  window.layer = layui.layer;
  window.laytpl = layui.laytpl;

  // 全局模块
  const _MeetingDemo = function () {
    // 加载层索引
    this.loadingIndex = null; // layui加载层索引，关闭加载层时需要

    // 会议中关闭页面弹出提示确认
    window.addEventListener('beforeunload', (e) => {
      if (MeetingDemo.RoomMgr.isMeeting) {
        // 部分浏览器支持 event.preventDefault() + return 部分浏览器支持 event.returnValue
        const event = e || window.event;
        const message = '正在会议中，仍然关闭？';
        event.preventDefault();
        if (e) event.returnValue = message;
        // 注册一个耗时计算的方法，让页面关的慢一点，确保离开房间的消息能发出去，这里先注册方法
        window.__fib = function (n) {
          return n < 2 ? n : __fib(n - 1) + __fib(n - 2);
        };
        return message;
      }
    });

    // 会议中确认关闭页面之后离开会议
    window.addEventListener('unload', (e) => {
      if (MeetingDemo.RoomMgr.isMeeting) {
        CRVideo_ExitMeeting('refresh'); // SDK接口：退出房间
        CRVideo_Logout(); // SDK接口：退出登录
        // 做一个耗时计算，让页面关的慢一点，确保离开房间的消息能发出去，这里触发方法，一定是在接口调用完之后再触发
        window.__fib(40);
      }
    });

    // 鼠标移入工具栏效果
    $('.page_meet_tool li')
      .mouseover(function () {
        // $(this).find("span").show();
        $(this).find('span').show().siblings().find('span').hide();
      })
      .mouseout(function () {
        $(this).find('span').hide().siblings().find('span').show();
      });

    // 页面加载先载入本地存储的房间号
    $('#g_meet_id').val(localStorage.getItem('CRMEETINGDEMO_MEETID'));

    // 监听键盘事件
    window.onkeypress = (event) => {
      var e = event || window.event || arguments.callee.caller.arguments[0];
      // 按下enter 键
      if (e && e.keyCode == 13) {
        this.onpressEnter();
      }
    };
    // 弹出layui警告
    this.alertLayer = (contents, yesFun) => {
      window.layer && this.removeLoading(); // 移除loading层
      window.layer.open({
        type: 0,
        time: 0,
        // area: 'auto',
        title: ['提示', 'font-size:14px;'],
        content: contents,
        btn: ['确定'],
        yes: function (index, layero) {
          yesFun != undefined ? yesFun() : '';
          window.layer.close(index);
        },
      });
    };
    // 弹出layui提示
    this.tipLayer = (msg, timer) => {
      window.layer && this.removeLoading(); // 移除loading层
      if (timer == undefined) timer = 3000;
      window.layer.open({
        title: 0,
        btn: 0,
        content: msg,
        closeBtn: 0,
        shade: 0,
        time: timer,
      });
    };
    // 弹出模态框
    this.modalLayer = (title, content, btnsObj, time) => {
      let btns = btnsObj.btns,
        btn1Callback = btnsObj.btn1Callback,
        btn2Callback = btnsObj.btn2Callback;
      window.layer.open({
        closeBtn: 0,
        time: time !== undefined ? time : 0,
        title: [title, 'font-size:14px'],
        content: content,
        btn: btns,
        btn1: function (index) {
          btn1Callback();
          window.layer.close(index);
        },
        btn2: function (index) {
          btn2Callback();
        },
      });
    };
    // 弹出输入框
    this.promptLayer = (formType, title, value, yesCallback) => {
      window.layer.prompt(
        {
          formType: formType || 2,
          value: value || '', // 默认值
          title: title || '请输入',
          // area: ['300px', '300px'] //自定义文本域宽高
        },
        function (value, index, elem) {
          yesCallback(value);
          window.layer.close(index);
        }
      );
    };
    // 弹出layui加载ing
    this.loadingLayer = (style, options) => {
      window.layer && this.removeLoading(); // 移除loading层
      if (!!style) {
        // style为 0 undefined null '' 等
        style = 0;
      }
      if (options == undefined) {
        options = {
          time: 15000, // 最多15秒自动关闭
        };
      }
      this.loadingIndex = window.layer.load(style, options);
    };
    // 移除layui加载
    this.removeLoading = () => {
      window.layer.close(this.loadingIndex);
    };
    // 移除弹出层
    this.closeLayer = (type) => {
      window.layer.closeAll(type == undefined ? '' : type);
    };
    // 判断是否是数组类型
    this.isArrayFn = (value) => {
      if (typeof Array.isArray === 'function') {
        return Array.isArray(value);
      } else {
        return Object.prototype.toString.call(value) === '[object Array]';
      }
    };
    // 获取当前时间
    this.getDate = () => {
      const date = new Date();
      let year = date.getFullYear(),
        month = date.getMonth() + 1,
        day = date.getDate(),
        hour = date.getHours(),
        minute = date.getMinutes(),
        second = date.getSeconds();

      month = month < 10 ? '0' + month : month;
      day = day < 10 ? '0' + day : day;
      hour = hour < 10 ? '0' + hour : hour;
      minute = minute < 10 ? '0' + minute : minute;
      second = second < 10 ? '0' + second : second;

      return {
        year,
        month,
        day,
        hour,
        minute,
        second,
      };
    };
    // 处理按下enter键
    this.onpressEnter = () => {
      if (MeetingDemo.RoomMgr.isMeeting && $('.page_meet_chat').css('display') !== 'none') {
        if ($('input[name=chat_msg]').val() !== '') {
          $('#sendMsg').click(); // 发送消息
        } else {
          $('input[name=chat_msg]')[0].focus(); // 获得焦点
        }
      }
    };
    // 刷新分屏样式
    this.refreshScreenSplit = () => {
      let number = 0;
      MeetingDemo.MemberMgr.members.forEach((member) => {
        member.allVideos.forEach((videoItem) => {
          if (videoItem.videoUI) {
            number++;
          }
        });
      });
      if (number > MeetingDemo.Video.pageVideoNum) number = MeetingDemo.Video.pageVideoNum;
      if (number == 0 || number == 1) {
        // 1分屏
        $('.page_screen').removeClass().addClass('page_screen screenOne');
        $('.page_screen').children().eq(0).show().nextAll().hide();
      } else if (number == 2) {
        // 2分屏
        $('.page_screen').removeClass().addClass('page_screen screenTwo');
        $('.page_screen').children().eq(1).show().prevAll().show();
        $('.page_screen').children().eq(1).show().nextAll().hide();
      } else if (number > 2 && number < 5) {
        // 4分屏
        $('.page_screen').removeClass().addClass('page_screen screenFour');
        $('.page_screen').children().eq(3).show().prevAll().show();
        $('.page_screen').children().eq(3).show().nextAll().hide();
      } else if (number > 4) {
        // 9分屏
        $('.page_screen').removeClass().addClass('page_screen screenNine');
        $('.page_screen').children().show();
      }
    };
    // 判断是否在全屏状态
    this.isFullScreen = () => {
      return document.isFullScreen || document.mozIsFullScreen || document.webkitIsFullScreen;
    };
    // 获取当前全屏的元素
    this.getFullscreenElement = () => {
      var fullscreenEle = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement;
      //注意：要在用户授权全屏后才能获取全屏的元素，否则 fullscreenEle为null
      fullscreenEle !== null ? console.log('全屏元素：', fullscreenEle) : '';
      return fullscreenEle;
    };
    // 退出全屏
    this.exitFullscreen = () => {
      if (!this.isFullScreen()) return;
      console.crlog(`[MeetingDemo] 退出全屏`);
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.msExitFullscreen) {
        document.msExiFullscreen();
      } else if (document.webkitCancelFullScreen) {
        document.webkitCancelFullScreen();
      }
    };
    // 点击设置按钮
    this.onClickSetBtn = () => {
      if ($('.page_open_set').css('display') == 'none') {
        MeetingDemo.Video.updateVideoDevices();
        MeetingDemo.Audio.updateAudioDevices();
        $('.page_open_set').show();
      } else {
        $('.page_open_set').hide();
      }
    };
    // 网络状态变化
    window.CRVideo_NetStateChanged.callback = (score) => {
      // console.crlog(`[MeetingDemo] 网络质量变化：${score}`);
      if (score > 8) {
        $('.net-state-icon').removeClass('bad midium none').addClass('fine');
      } else if (score > 5) {
        $('.net-state-icon').removeClass('bad fine none').addClass('midium');
      } else if (score >= 0) {
        $('.net-state-icon').removeClass('fine midium none').addClass('bad');
      } else {
        $('.net-state-icon').removeClass('fine midium bad').addClass('none');
      }
    };
  };
  const MeetingDemo = (window.MeetingDemo = new _MeetingDemo());

  // 登录模块
  class _loginM {
    constructor() {
      this.initData();
      this.registerCallback();
      this.initDomEvent();
      $('#sdkver').text(CRVideo_GetSDKVersion());
      setTimeout(() => {
        const paramsStr = decodeURI(window.location.href.split('?')[1]),
          paramsArr = paramsStr ? paramsStr.split('&') : [],
          paramsObj = new Object();
        paramsArr.length > 0 &&
          paramsArr.forEach((item, index) => {
            const _key = item.split('=')[0],
              _value = item.split('=')[1];
            paramsObj[_key] = _value;
          });

        console.crlog(`[MeetingDemo] url参数：${JSON.stringify(paramsObj)}`);

        $('#userInputName').val(this.nickname.toString());

        // url带房间号，链接入会
        if (paramsObj.meetID !== undefined) {
          MeetingDemo.RoomMgr.meetID = paramsObj.meetID;
          $('#g_meet_id').val(paramsObj.meetID);

          // url带token(base64)
          if (paramsObj.token) {
            this.token = window.atob(paramsObj.token); // base64解码
            this.authType = '2'; // 选择token鉴权模式
            $('#loginToken').val(this.token);
            $('#loginTokeRadio').click();
          }

          // url带服务器地址
          if (paramsObj.server) {
            this.server = paramsObj.server;
            $('#server_add').val(this.server);
          }

          // url不带昵称，需要输入昵称
          if (paramsObj.nickname === undefined) {
            window.layer.prompt(
              {
                formType: 0,
                title: '请输入您的昵称',
                value: this.nickname,
              },
              function (value, index, elem) {
                window.layer.close(index);
                MeetingDemo.Login.nickname = value.toString();
                // MeetingDemo.Login.userID = `${MeetingDemo.Login.nickname}_${Math.floor(Math.random() * 899) + 100}`;
                MeetingDemo.Login.userID = MeetingDemo.Login.nickname;
                $('#userInputName').val(MeetingDemo.Login.nickname);
                MeetingDemo.Login.initSDK('urlEnter'); // 页面加载完自动初始化并登录
              }
            );

            // url带昵称，直接入会
          } else {
            this.nickname = paramsObj.nickname ? paramsObj.nickname : this.nickname;
            // this.userID = paramsObj.userid ? paramsObj.userid : `${this.nickname}_${Math.floor(Math.random() * 899) + 100}`;
            this.userID = paramsObj.userid ? paramsObj.userid : this.nickname;
            $('#userInputName').val(this.nickname);
            MeetingDemo.Login.initSDK('urlEnter'); // 页面加载完自动初始化并登录
          }

          // url不带会议号，登录界面入会
        } else {
          this.initSDK(); // 页面加载完自动初始化并登录
        }
      }, 0);
    }
    initData() {
      this.isSetServer = false;
      this.storage = JSON.parse(localStorage.getItem('CRMEETINGDEMO_LOGIN')) || {}; // 存储在session的登录参数
      this.server = this.storage.server || window.location.host || ''; // 登录的服务器地址
      this.authType = this.storage.authType || $('input[name=login_set]:checked').val(); // 鉴权方式 "1" appID鉴权 "2" token鉴权
      this.appID = this.storage.appID || $('#cr_account').val(); // 登录的账号（appID）
      this.appSecret = this.storage.appSecret || $('#comp_psdw').val(); // 登录的密码
      this.token = this.storage.token || $('#loginToken').val(); // token鉴权方式登录的token
      this.protocol = this.storage.protocol || $('input[name=msTypeSet]:checked').val(); // 流媒体转发协议
      this.userAuthCode = this.storage.userAuthCode || $('#userAuthCode').val(); // 启用第三方鉴时的鉴权参数
      this.nickname = sessionStorage.getItem('CRMEETINGDEMO_NICKNAME') || `H5用户${Math.floor(Math.random() * 899) + 100}`; // 登录昵称
      // this.userID = sessionStorage.getItem('CRMEETINGDEMO_UID') || `${this.nickname}_${Math.floor(Math.random() * 899) + 100}`; // 登录SDK系统的用户唯一ID
      this.userID = sessionStorage.getItem('CRMEETINGDEMO_UID') || this.nickname; // 登录SDK系统的用户唯一ID
      this.isLogin = false; // 是否已经登录
      this.reLoginTimer = null; // 掉线重登计时器
      this.reLoginTimes = null; // 掉线重登重试次数

      $('#userInputName').val(this.nickname);
    }
    registerCallback() {
      // SDK接口：回调 登录成功
      CRVideo_LoginSuccess.callback = (UID, cookie) => {
        this.isLogin = true;
        this.reLoginTimes = 0; // 重置重登次数
        this.setLoginStorage();
        $('.login_form').css('border', '1px solid green');
        $('#meetNickName').text(`昵称：${this.nickname}`);
        $('#meetUserID').text(`UID：${this.userID}`);
        console.crlog(`[MeetingDemo] 登录成功：${UID}`);
        if (cookie == 'urlEnter' || cookie == 'loginAndEnter') {
          // 链接入会 或者 非自动登录状态下点击进入房间按钮
          MeetingDemo.RoomMgr.enterMeetingFun(cookie);
        } else if (cookie == 'loginAndCreate') {
          // 非自动登录状态下点击创建房间按钮
          MeetingDemo.RoomMgr.onClickCreateBtn();
        } else {
          // 自动登录，登录成功
          MeetingDemo.tipLayer(`登录成功：${UID}`);
        }

        // 快捷测试vp8编码和h264编码（SDK内部测试用，开发者无需关注）
        if (UID.includes('H264')) __Rtc.rtc_codecs = 'H264';
        if (UID.includes('VP8')) __Rtc.rtc_codecs = 'VP8';
      };
      // SDK接口：回调 登录失败
      CRVideo_LoginFail.callback = (sdkErr, cookie) => {
        this.isLogin = false;
        $('.login_form').css('border', 'none');
        console.crlog(`[MeetingDemo] 登录服务器失败，错误码：${sdkErr}, cookie:${cookie}`);
        if (!!cookie && cookie.includes('reLogin') && cookie.split('_')[1] <= 10) {
          setTimeout(() => {
            this.loginSystem(`reLogin_${++this.reLoginTimes}`);
          }, 2000);
          return;
        } else if (!!cookie && cookie.includes('reLogin') && cookie.split('_')[1] > 10) {
          $('.page_meet_close').click();
          MeetingDemo.alertLayer(`网络错误，多次尝试重登失败，您已掉线！请在网络恢复后刷新页面重新登录...`);
          return;
        } else {
          sdkErr == 5 ? (sdkErr = '参数错误') : sdkErr;
          sdkErr == 7 ? (sdkErr = '用户名或密码错误！') : sdkErr;
          sdkErr == 14 ? (sdkErr = '缺少第三方鉴权信息！') : sdkErr;
          sdkErr == 15 ? (sdkErr = '该项目没有启用第三方鉴权！') : sdkErr;
          sdkErr == 17 ? (sdkErr = '第三方鉴权失败！') : sdkErr;
          sdkErr == 21 ? (sdkErr = 'Token鉴权失败！') : sdkErr;
          sdkErr == 18 ? (sdkErr = 'Token已过期！') : sdkErr;
          sdkErr == 20 ? (sdkErr = '鉴权appID不存在！') : sdkErr;
          sdkErr == 22 ? (sdkErr = '此appID非Token鉴权！') : sdkErr;
          sdkErr == 202 ? (sdkErr = '网络异常！') : sdkErr;
          sdkErr == 204 ? (sdkErr = 'socket连接失败！') : sdkErr;
          MeetingDemo.removeLoading(); // 隐藏加载层
          MeetingDemo.alertLayer('登录服务器失败，请稍后再试: ' + sdkErr);
        }
      };
      // SDK接口：通知 Token即将失效
      CRVideo_NotifyTokenWillExpire.callback = () => {
        window.layer.prompt(
          {
            formType: 2,
            value: '',
            title: 'Token即将失效，请立即更新!',
            area: ['200px', '180px'], //自定义文本域宽高
          },
          function (value, index, elem) {
            // SDK接口：更新Token
            CRVideo_UpdateToken(value);
            window.layer.close(index);
          }
        );
      };
      // SDK即可：通知 从服务器掉线了
      CRVideo_LineOff.callback = (sdkErr) => {
        this.isLogin = false;
        $('.login_form').css('border', 'none');
        console.crlog(`[MeetingDemo] 从系统掉线了！错误码：${sdkErr}`);
        if (sdkErr == 10) {
          MeetingDemo.alertLayer(`您的ID已在其它设备登录，您已自动退出房间...`, () => {
            MeetingDemo.RoomMgr.onClickCloseBtn(1);
          });
        } else if (sdkErr == 18) {
          MeetingDemo.alertLayer(`Token失效，已从系统中断开！`);
          MeetingDemo.RoomMgr.onClickCloseBtn(1);

          $('#page_meeting').animate(
            {
              width: '0px',
            },
            300
          );
          $('#page_login').animate(
            {
              width: '100%',
            },
            300
          );
        } else {
          clearTimeout(this.reLoginTimer);

          // 这里不再自动重登呼叫系统了，只自动重试进入房间，进入房间之后再去判断一下，如果登录掉线了就重新登录一下

          // this.reLoginTimer = setTimeout(() => {
          //     console.crlog(`[MeetingDemo] 掉线，重新登录...`);
          //     this.loginSystem(`reLogin_${++this.reLoginTimes}`);
          // }, 5000);
        }
      };
    }
    // 注册事件
    initDomEvent() {
      // 切换token登录或密码登录
      $('input[name=login_set]').click((e) => {
        const authType = e.target.value;
        if (authType === '1') {
          console.crlog(`[MeetingDemo] 切换成密码鉴权`);
          $('.form-account').show();
          $('.form-password').show();
          $('.form-token').hide();
        } else if (authType === '2') {
          console.crlog(`[MeetingDemo] 切换成Token鉴权`);
          $('.form-account').hide();
          $('.form-password').hide();
          $('.form-token').show();
        }
      });

      // 输入昵称
      $('#userInputName').change((e) => {
        this.nickname = e.target.value;
        this.userID = this.nickname;
        if (this.isLogin) {
          this.logoutSystem();
          this.loginSystem();
        } else {
          this.loginSystem();
        }
      });
    }
    // 存储登录数据
    setLoginStorage() {
      const storage = {
        server: this.server,
        authType: this.authType,
        appID: this.appID,
        appSecret: this.appSecret,
        token: this.token,
        protocol: this.protocol,
        userAuthCode: this.userAuthCode,
      };
      localStorage.setItem('CRMEETINGDEMO_LOGIN', JSON.stringify(storage));
      sessionStorage.setItem('CRMEETINGDEMO_NICKNAME', this.nickname);
      sessionStorage.setItem('CRMEETINGDEMO_UID', this.userID);
    }
    // 点击登录设置
    clickLoginSel() {
      if ($('.logset_hide').css('display') == 'none') {
        $('#server_add').val(this.server);
        $('#cr_account').val(this.appID);
        $('#comp_psdw').val(this.appSecret);
        $('#userAuthCode').val(this.userAuthCode);
        if (this.authType === '1') {
          $('#loginPassRadio').click(); // 密码登录
        } else {
          $('#loginTokeRadio').click(); // Token登录
        }
        if (this.protocol === '0') {
          $('#msTypeUDPTCP').click(); // UDP/TCP
        } else if (this.protocol === '1') {
          $('#msTypeUDP').click(); // UDP
        } else {
          $('#msTypeTCP').click(); // TCP
        }
        $('#loginToken').val(this.token);

        // $(".login_cont").css("top", "-230px")
        $('.login_cont').animate(
          {
            top: '-230px',
          },
          150
        );
        $('#login_sel').css('background-image', 'url("./image/pc/login_arrows_up.png")');
        $('.logset_hide').slideDown(150);
      } else {
        // $(".login_cont").css("top", "0")
        $('.login_cont').animate(
          {
            top: '0px',
          },
          150
        );
        $('#login_sel').css('background-image', 'url("./image/pc/login_arrows_down.png")');
        $('.logset_hide').slideUp(150);
      }
    }
    // 点击设置-重置按钮
    resetLoginParam() {
      const host = window.location.host; // 登录的服务器地址
      if (host.includes('127.0.0.1') || host.includes('localhost') || !host) {
        this.server = '';
      } else {
        this.server = location.host;
      }
      $('#server_add').val(this.server);
      $('#loginPassRadio').click(); // 密码登录
      $('#msTypeUDP').click(); // UDP
      $('#cr_account').val('默认');
      $('#comp_psdw').val('默认');
      $('#userAuthCode').val('');
      $('#loginToken').val('');
    }
    // 点击设置-确定按钮
    saveLoginParam() {
      if (!$('#server_add').val() || !$('#cr_account').val() || !$('#comp_psdw')) {
        MeetingDemo.tipLayer('必要参数不能为空！');
        return;
      }
      this.server = $('#server_add').val(); // 服务器地址
      this.authType = $('input[name=login_set]:checked').val(); // 鉴权方式 "1" appID鉴权 "2" token鉴权
      this.appID = $('#cr_account').val(); // 登录的账号（appID）
      this.appSecret = $('#comp_psdw').val(); // 登录的密码
      this.token = $('#loginToken').val(); // token鉴权方式登录的token
      this.protocol = $('input[name=msTypeSet]:checked').val(); // 流媒体转发协议
      this.userAuthCode = $('#userAuthCode').val(); // 启用第三方鉴时的鉴权参数
      let changed = false;
      const storage = JSON.parse(localStorage.getItem('CRMEETINGDEMO_LOGIN'));
      for (var key in storage) {
        if (this[key] == undefined || this[key] != storage[key]) changed = true;
      }
      if (changed || this.isLogin == false) {
        this.setLoginStorage();
        this.logoutSystem();
        this.loginSystem();
      }
      $('#login_sel').click();
    }
    // 初始化SDK
    initSDK(enterType) {
      MeetingDemo.loadingLayer();
      CRVideo_Init().then(
        (res) => {
          this.isInit = true;
          this.setSDKParams();
          this.loginSystem(enterType);
        },
        (errCode) => {
          let errDesc = '';
          switch (errCode) {
            case 8001:
              errDesc = '初始化媒体设备权限发生未知错误';
              break;
            case 8002:
              errDesc = '用户拒绝授予网页媒体设备权限';
              break;
            case 8003:
              errDesc = '初始化枚举媒体设备列表失败';
              break;
            case 8004:
              errDesc = '浏览器缺少必要API（当前网页非https://协议或浏览器版本过低）';
              break;
            case 8006:
              errDesc = '浏览器版本过低';
              break;
            case 8007:
              errDesc = '初始化媒体设备失败（设备发生错误或正在被占用）';
              break;
            default:
              break;
          }
          if (errCode === 8001 || errCode === 8002 || errCode === 8007) {
            this.isInit = true;
            this.setSDKParams();
            this.loginSystem(enterType);
          } else {
            console.crlog(`[MeetingDemo] 初始化失败：${errCode}`);
            MeetingDemo.tipLayer(`登录初始化失败：${errCode} ${errDesc}`);
            MeetingDemo.removeLoading(); // 隐藏加载层
          }
        }
      );
    }
    // 设置SDK参数
    setSDKParams() {
      // SDK接口：设置SDK参数
      CRVideo_SetSDKParams({
        MSProtocol: this.protocol, // 媒体流传输协议 TCP UDP 详见文档
        virtualBackgroundAssets: '../SDK/VirtualBackgroundSource', //虚拟背景资源路径
        // virtualBackgroundAssets: "https://cdn.jsdelivr.net/npm/@VirtualBackgroundSource/selfie_segmentation", //虚拟背景资源路径
        // virtualBackgroundAssets: "https://www.unpkg.com/@VirtualBackgroundSource/selfie_segmentation", //虚拟背景资源路径
        // svrTimeout: 120, // 与服务器通信超时时间 缺省为60s
        // isHttp: true, // 是否强制sdk内部使用http协议（和页面协议无关） 缺省为false
        // securityEnhancement: true, //是否开启安全增强（会有跨域问题，需配置跨域响应头） 缺省为false
        // isSDKConsole: false, // 是否在控制台输出SDK日志  缺省为true
        // isUploadLog: false, // 是否上传日志  缺省为true
        // isRtcLog: false, // 是否输出RTC日志  缺省为true
        // isCallSer: false, // 是否登录呼叫服务  缺省为true
      });
    }
    // 登录系统
    loginSystem(cookie) {
      // SDK接口：设置服务器地址
      CRVideo_SetServerAddr(this.server);
      this.isSetServer = true;
      const nickname = this.nickname,
        UID = this.userID,
        code = this.userAuthCode;
      if (nickname.length == 0 || UID.length == 0) return MeetingDemo.tipLayer('昵称不能为空');
      // if (nickname.length > 30 || UID.length > 30) return MeetingDemo.tipLayer('昵称太长');
      if (this.authType === '1') {
        // appID鉴权
        let appID = this.appID,
          appSecret = this.appSecret;
        if (appSecret.length == 32 || appSecret == '默认') {
          // SDK接口：使用账号密码登录系统
          CRVideo_Login(appID, appSecret, nickname, UID, code, cookie);
        } else {
          // SDK接口：使用账号密码登录系统
          CRVideo_Login(appID, md5(appSecret), nickname, UID, code, cookie);
        }
      } else if (this.authType === '2') {
        // token鉴权
        const token = this.token;
        // SDK接口：使用Token登录系统
        CRVideo_LoginByToken(token, nickname, UID, code, cookie);
      }
    }
    // 登出系统
    logoutSystem() {
      CRVideo_Logout();
      this.isLogin = false;
      console.crlog(`[MeetingDemo] isLogin:${this.isLogin}`);
    }
  }
  MeetingDemo.Login = new _loginM();

  // 房间管理模块
  class _roomMgr {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.meetID = null; // 房间号
      this.isMeeting = false; // 当前是否正在会话中
      this.reEnterTimes = 0; // 进房间重试的次数
    }
    registerCallback() {
      // SDK接口:回调 创建房间成功
      CRVideo_CreateMeetingSuccess.callback = (meetObj, cookie) => {
        console.crlog(`[MeetingDemo] 创建房间成功, ${JSON.stringify(meetObj)}`);
        // 拿到房间号之后进入会议
        this.meetID = meetObj.ID; // 存储会议信息
        this.enterMeetingFun(); // 进入房间
      };
      // SDK接口：回调 创建房间失败
      CRVideo_CreateMeetingFail.callback = (sdkErr, cookie) => {
        console.crlog(`[MeetingDemo] 创建房间失败！${sdkErr}`);
        MeetingDemo.alertLayer(`创建房间失败,请重试！错误码：${sdkErr}`);
      };
      // SDK接口：回调 进入房间的结果
      CRVideo_EnterMeetingRslt.callback = (sdkErr, cookie) => {
        this.enterMeetingRslt(sdkErr, cookie);
      };
      // SDK接口：通知 房间被结束
      CRVideo_MeetingStopped.callback = (id) => {
        MeetingDemo.alertLayer('<p>当前房间已被关闭！</p><p>请重新创建房间或进入其它正在进行中的房间。</p>', () => {
          this.isMeeting = false;
          window.location.reload(); // 刷新当前页面
        });
      };
      // SDK接口：通知 从房间中掉线了
      CRVideo_MeetingDropped.callback = () => {
        this.isMeeting = false;

        // // 自动重新入会
        // setTimeout(() => {
        //   MeetingDemo.tipLayer(`从房间中掉线了，正在第${++this.reEnterTimes}次尝试重新进入...`);
        //   this.enterMeetingFun(`reEnter_${this.reEnterTimes}`); // 进入房间
        // }, 0);

        // 弹框提示掉线
        MeetingDemo.modalLayer(`掉线`, `您已从房间中掉线，是否重新进入？`, {
          btns: ['重进', '取消'],
          btn1Callback() {
            MeetingDemo.RoomMgr.enterMeetingFun(`reEnter_${++MeetingDemo.RoomMgr.reEnterTimes}`); // 进入房间
          },
          btn2Callback() {
            MeetingDemo.RoomMgr.onClickCloseBtn();
          },
        });
      };
    }
    // 点击创建房间按钮
    onClickCreateBtn() {
      console.crlog(`[MeetingDemo] 点击创建房间按钮`);
      if (!MeetingDemo.Login.isSetServer || !MeetingDemo.Login.isLogin) return MeetingDemo.Login.initSDK('loginAndCreate');
      MeetingDemo.loadingLayer();
      // SDK接口：创建会议
      CRVideo_CreateMeeting2();
    }
    // 点击进入房间按钮
    onClickEnterBtn() {
      console.crlog(`[MeetingDemo] 点击进入房间按钮`);
      if (!MeetingDemo.Login.isSetServer || !MeetingDemo.Login.isLogin) return MeetingDemo.Login.initSDK('loginAndEnter');
      const MeetID = $('#g_meet_id').val();
      if (!MeetID) {
        MeetingDemo.alertLayer('房间号不能为空！');
        return;
      } else if (MeetID.length !== 8) {
        MeetingDemo.alertLayer('请输入正确的8位房间号！');
        return;
      } else {
        this.meetID = MeetID;
        if (!this.meetID) return;
        MeetingDemo.loadingLayer();
        this.enterMeetingFun(); // 进入房间
      }
    }
    // 进入房间的方法
    enterMeetingFun(cookie) {
      if (!this.meetID) this.meetID = $('#g_meet_id').val() || null;
      // SDK接口：进入房间
      this.meetID && CRVideo_EnterMeeting3(this.meetID, cookie);
    }
    // 进入房间的结果
    enterMeetingRslt(sdkErr, cookie) {
      // 进入房间成功
      if (sdkErr == 0) {
        console.crlog(`[MeetingDemo] 进入房间成功，cookie:${cookie}`);
        if (!MeetingDemo.Login.isLogin) MeetingDemo.Login.loginSystem(); // 如果呼叫系统掉线了，就重登一下呼叫系统
        this.isMeeting = true; // 是否正在会话中
        this.reEnterTimes = 0; // 重试次数归零
        if ($('#mutiCam')[0].checked == true) CRVideo_SetEnableMutiVideo(MeetingDemo.Login.userID, true); // SDK接口：设置是否启用多摄像头
        MeetingDemo.Screen.onScreenShareStoped(); // 恢复屏幕共享状态
        MeetingDemo.Media.stopPlayingHandler(); // 恢复影音共享状态
        localStorage.setItem('CRMEETINGDEMO_MEETID', this.meetID); // 存储房间号
        $('#g_meet_id').val(this.meetID); // 登录页面房间号输入
        $('#meetId').text(`房间号：${this.meetID}`); // 会话界面展示房间号
        // 更新所有媒体设备的信息，摄像头、麦克风、扬声器
        MeetingDemo.Video.updateVideoDevices();
        MeetingDemo.Audio.updateAudioDevices();
        // 设置初始视频参数
        MeetingDemo.Video.setVideoConfig({
          width: +$('#select_size').val().split('*')[0],
          height: +$('#select_size').val().split('*')[1],
          fps: +$('#select_frame').val(),
        });
        // 创建大小流视频组件
        MeetingDemo.Video.createSubStreamVideoUI();

        // 打开自己的摄像头和麦克风
        MeetingDemo.Video.openVideo(MeetingDemo.Login.userID); // 打开自己的摄像头
        MeetingDemo.Audio.openMic(MeetingDemo.Login.userID); // 打开自己的麦克风

        MeetingDemo.MemberMgr.initData();
        MeetingDemo.Video.refreshUserVideoWall(0); // 展示视频墙
        MeetingDemo.removeLoading(); // 隐藏加载层
        // 隐藏登录页面
        $('#page_login').animate(
          {
            width: '0px',
          },
          300
        );
        // 显示会话页面
        $('#page_meeting').animate(
          {
            width: '100%',
          },
          300
        );
        setTimeout(() => {
          MeetingDemo.Mixer.getAllCloudMixerInfo();
          MeetingDemo.Mixer.updateInterflowRecord();
        }, 1000);

        // 进入房间失败
      } else {
        console.crlog(`[MeetingDemo] 进入房间失败，错误码：${sdkErr}，cookie:${cookie}`);
        if (![1, 9, 201, 800, 801, 802, 805, 806].includes(sdkErr)) {
          // 通过cookie来判断是否是重登，如果是重登，网络恢复需要时间，可以多尝试几次
          if (!!cookie && cookie.includes('reEnter') && cookie.split('_')[1] < 10) {
            setTimeout(() => {
              MeetingDemo.tipLayer(`进入房间失败，正在第${++this.reEnterTimes}次尝试重新进入...`);
              this.enterMeetingFun(`reEnter_${this.reEnterTimes}`); // 进入房间
            }, 1000);
            return;
          } else if (!!cookie && cookie.includes('reEnter') && cookie.split('_')[1] >= 10) {
            MeetingDemo.modalLayer(`失败`, `您已从房间中掉线，多次尝试重新进入房间失败，是否再次重试？`, {
              btns: ['重试', '取消'],
              btn1Callback() {
                MeetingDemo.RoomMgr.enterMeetingFun(`reEnter_${++MeetingDemo.RoomMgr.reEnterTimes}`); // 进入房间
              },
              btn2Callback() {
                MeetingDemo.RoomMgr.onClickCloseBtn();
              },
            });
          }
        } else {
          let errDesc = '';
          switch (sdkErr) {
            case 1:
              errDesc = '未知错误';
              break;
            case 9:
              errDesc = '登录状态异常';
              break;
            case 201:
              errDesc = '没有可用服务器';
              break;
            case 800:
              errDesc = '房间不存在或已结束';
              break;
            case 801:
              errDesc = '房间密码错误';
              break;
            case 802:
              errDesc = '服务器授权到期或超出并发数！';
              break;
            case 805:
              errDesc = '余额不足！';
              break;
            case 806:
              errDesc = '超出并发数！';
              break;
            default:
              errDesc = `请稍后再试！错误码：${sdkErr}`;
              break;
          }
          MeetingDemo.alertLayer(`进入房间失败！${errDesc}`);
        }
      }
    }
    // 退出房间
    exitMeeting(iskick) {
      $('#page_meeting').animate(
        {
          width: '0px',
        },
        300
      );
      $('#page_login').animate(
        {
          width: '100%',
        },
        300
      );
      MeetingDemo.Video.closeSubStreamWindow();

      if (this.isMeeting) {
        // if (MeetingDemo.Record.isMyRecord) MeetingDemo.Record.stopRecord(); // 停止录制
        if (MeetingDemo.Screen.isMySharing) {
          MeetingDemo.Screen.onClickStopScreenShareBtn(); // 停止共享
          MeetingDemo.Sync.switchToPage(8); // 切到视频墙
        }
        if (MeetingDemo.Media.isMyPlaying) {
          MeetingDemo.Media.onClickStopMediaBtn(); // 停止播放
          MeetingDemo.Sync.switchToPage(8); // 切到视频墙
        }
        MeetingDemo.Video.removeScreenCam();
      }

      setTimeout(() => {
        !iskick && CRVideo_ExitMeeting(); // SDK接口：退出房间
        // 复原界面
        $('.page_chat_box ul').html(''); // 清空聊天记录
        $('.page_screen').removeClass().addClass('page_screen'); // 恢复分屏数
        for (var i = 0; i < 9; i++) {
          $('.page_screen').children().eq(i).html(`待进入`);
        }
        $('.page_open_set').hide();
        $('.more-box').hide();
        $('.page_meet_video').show();
        $('.page_share_box').hide();
        $('.page_meet_chat').show();
        $('.page_chat_box').show();
      }, 300);

      // 重置所有模块的数据
      for (let key in MeetingDemo) {
        if (MeetingDemo[key] && MeetingDemo[key].initData !== undefined && key !== 'Login') {
          MeetingDemo[key].initData();
        }
      }
    }
    // 点击退出按钮
    onClickCloseBtn(iskick) {
      this.exitMeeting(iskick);
    }
    // 点击分享会议按钮
    onClickShareUrlBtn() {
      const url = `${window.location.origin}${window.location.pathname}?meetID=${this.meetID}`;
      const input = document.querySelector('#copyInput');
      input.value = url;
      input.select();
      document.execCommand('copy');
      MeetingDemo.modalLayer('邀请参会', `会议链接已复制，去粘贴发送给别人吧！`, {
        btns: ['确定'],
        btn1Callback() { },
      });
    }
  }
  MeetingDemo.RoomMgr = new _roomMgr();

  // 成员管理模块
  class _memberM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.members = []; // 房间成员列表
    }
    registerCallback() {
      // SDK接口：通知 有新成员进入房间
      CRVideo_UserEnterMeeting.callback = (UID) => {
        this.userEnter(UID);
      };
      // SDK接口：通知 有成员离开房间
      CRVideo_UserLeftMeeting.callback = (UID, reson) => {
        this.userLeft(UID, reson);
      };
      // SDK接口：通知 成员昵称改变
      CRVideo_NotifyNickNameChanged.callback = (UID, oldName, newName) => {
        this.members.forEach((item) => {
          if (item.userID == UID) item.nickname = newName;
        });
        if (UID == MeetingDemo.Login.userID) {
          MeetingDemo.Login.nickname = newName;
          $('#meetNickName').html(`昵称：${newName}`);
        }
      };
    }
    // 成员进入房间
    userEnter(UID) {
      // this.refreshAllmembersInfo(); // 刷新成员列表
      MeetingDemo.Video.refreshUserVideoWall(MeetingDemo.Video.curVideoPage); // 刷新视频墙
      if (UID != MeetingDemo.Login.userID) {
        MeetingDemo.tipLayer(CRVideo_GetMemberNickName(UID) + ' 进入房间 ...', 2000);
        MeetingDemo.Mixer.updateInterflowRecord();
      }
    }
    // 成员离开房间
    userLeft(UID, reson) {
      if (UID != MeetingDemo.Login.userID) {
        try {
          const leftUser = this.members.find((item) => {
            return item.userID == UID;
          });
          MeetingDemo.tipLayer(`${leftUser.nickname} 离开房间...`, 2000);
        } catch (e) {
          console.error(e);
        }
      } else {
        if (reson == 'kick') {
          MeetingDemo.alertLayer(`您已被请出房间！`, () => {
            MeetingDemo.RoomMgr.onClickCloseBtn(1);
          });
        }
      }
      // this.refreshAllmembersInfo(); // 刷新成员列表
      MeetingDemo.Video.refreshUserVideoWall(MeetingDemo.Video.curVideoPage); // 刷新视频墙
      MeetingDemo.Mixer.updateInterflowRecord();
    }
    // 刷新成员列表
    refreshAllmembersInfo() {
      const members = window.CRVideo_GetAllMembers(); // SDK接口：获取会议内所有成员信息
      members.forEach((memberItem) => {
        const user = this.members.find((item) => memberItem.userID == item.userID);
        if (user) {
          // 已经存在列表中的成员，更新状态
          user.audioStatus = memberItem.audioStatus;
          user.videoStatus = memberItem.videoStatus;
        } else {
          // 列表中不存在的成员，添加
          this.members.push(memberItem);
        }
      });
      this.members.forEach((memberItem, index) => {
        const user = members.find((item) => item.userID == memberItem.userID);
        if (!user) {
          if (memberItem.allVideos && memberItem.allVideos.length > 0) {
            for (let i = 0; i < memberItem.allVideos.length; i++) {
              memberItem.allVideos[i].videoUI.destroy();
            }
          }
          this.members.splice(index, 1); // 删除已经不在房间的成员
        }
      });
      console.crlog(`[MeetingDemo] 刷新成员列表：${JSON.stringify(this.members)}`);
    }
    // 创建每个成员的状态控制图标
    createUserIcon(UID, videoID, UIID) {
      let parsedID = MeetingDemo.MemberMgr.parseUserID(UID);
      const htmlStr = `<div class="deviceStatus" data-userid="${parsedID}" data-videoid="${videoID}" data-UIID="${UIID}">
                    <div class="deviceIconText"></div>
                    <div data-title="开/关摄像头" class="deviceIcon deviceCam" onclick="MeetingDemo.Video.onClickUserIconCam(this)"></div>
                    <div data-title="开/关麦克风" class="deviceIcon deviceMic" onclick="MeetingDemo.Audio.onClickUserIconMic(this)"></div>
                    <div data-title="拍照" class="deviceIcon devicePhoto" onclick="MeetingDemo.Video.onClickUserIconSave(this)"></div>
                    <div data-title="修改昵称" class="deviceIcon deviceRename" onclick="MeetingDemo.MemberMgr.onClickRename(this)"></div>
                    <div data-title="观看大小流" class="deviceIcon watchStream" onclick="MeetingDemo.Video.onClickWatchStream(this)"></div>
                    <div data-title="请出房间" class="deviceIcon deviceKickout" onclick="MeetingDemo.MemberMgr.onClickKickOut(this)"></div>
                </div>`;
      const htmlEle = $(htmlStr)[0];
      return htmlEle;
    }
    // 更新某个成员的状态图标
    refreshUserIconStatus(UID) {
      let parsedID = MeetingDemo.MemberMgr.parseUserID(UID);
      const $deviceCam = $('[data-userid=' + parsedID + '] .deviceCam');
      const $deviceMic = $('[data-userid=' + parsedID + '] .deviceMic');
      const isSelf = UID == MeetingDemo.Login.userID ? true : false;
      this.members.forEach((item) => {
        if (item.userID == UID) {
          if (item.videoStatus == 3) {
            // 开启
            $deviceCam.addClass('deviceCamActive');
            !!isSelf && $('#openCamBtn').addClass('cam_open').removeClass('cam_close');
          } else {
            // 关闭
            $deviceCam.removeClass('deviceCamActive');
            !!isSelf && $('#openCamBtn').addClass('cam_close').removeClass('cam_open');
          }
          if (item.audioStatus == 3) {
            // 开启
            $deviceMic.addClass('deviceMicActive');
            !!isSelf && $('#openMicBtn').addClass('mic_open').removeClass('mic_close');
          } else {
            // 关闭
            $deviceMic.removeClass('deviceMicActive');
            !!isSelf && $('#openMicBtn').addClass('mic_close').removeClass('mic_open');
          }
        }
      });
    }
    // 点击修改昵称
    onClickRename(dom) {
      const $this = $(dom);
      const parsedID = $this.parent().data('userid');
      window.layer.prompt(
        {
          formType: 0,
          title: '请输入新昵称',
        },
        function (value, index, elem) {
          window.layer.close(index);
          const user = window.CRVideo_GetAllMembers().find((item) => MeetingDemo.MemberMgr.parseUserID(item.userID) == parsedID);
          if (user) {
            const oldName = CRVideo_GetMemberNickName(user.userID);
            // SDK接口：修改成员昵称
            CRVideo_SetNickName(user.userID, value)
              .then((res) => {
                MeetingDemo.tipLayer(`${oldName} 昵称已变更为：${res.newname}`);
              })
              .catch((err) => {
                console.log(`改名失败`);
              });
          }
        }
      );
    }
    // 点击踢人按钮
    onClickKickOut(dom) {
      const $this = $(dom);
      const parsedID = $this.parent().data('userid');
      const user = window.CRVideo_GetAllMembers().find((item) => MeetingDemo.MemberMgr.parseUserID(item.userID) == parsedID);
      if (user) {
        if (user.userID == MeetingDemo.Login.userID) {
          MeetingDemo.tipLayer('不能踢自己！');
        } else {
          const nickname = CRVideo_GetMemberNickName(user.userID);
          // SDK接口：踢人
          CRVideo_Kickout(user.userID)
            .then(() => {
              MeetingDemo.tipLayer(`${nickname} 已被请出房间`);
            })
            .catch((err) => {
              console.log(`将 ${nickname} 请出房间失败！${JSON.stringify(err)}`);
            });
        }
      }
    }
    // 处理userID带各种符号情况
    parseUserID(userID) {
      // jq选择器 必须以字母 A-Z 或 a-z 开头
      // 其后的字符：字母(A-Za-z)、数字(0-9)、连字符("-")、下划线("_")、冒号(":") 以及点号(".")
      // 值对大小写敏感
      return `_${md5(userID)}`;
    }
  }
  MeetingDemo.MemberMgr = new _memberM();

  // 视频管理模块
  class _videoM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      // this.curCam = null; // 当前默认摄像头
      this.nameStyle = {
        // 视频容器昵称样式
        left: '10px',
        top: '10px',
        backgroundColor: 'rgba(0, 0, 0, .7)',
        padding: '0 10px',
        borderRadius: '15px',
        display: 'block',
      };
      this.curVideoPage = 0; // 当前视频墙页码
      this.pageVideoNum = +$('#select_pageVideoNum').val(); // 分屏数
      this.vCamInfo = {
        // 当前虚拟摄像头信息
        camNo: 0,
        // type: 'img',
        // url: './image/aiman.png',
        // canvas,
        // ctx,
      };
      this.curPageVideos = []; // 当前视频墙展示的视频
      this.vbimgurl = '';
      this.ipCamCount = 0;
      this.showVideoSize = $('#showVideSize').is(':checked'); // 视频组件是否显示视频尺寸
      $('.bgimg-choose').hide();
      $('.choose-list li').removeClass('active');
    }
    registerCallback() {
      // SDK接口：通知 成员的摄像头设备变化
      CRVideo_VideoDevChanged.callback = (UID) => {
        this.memberVideoDevChange(UID);
      };
      // SDK接口：通知 成员的摄像头状态变化
      CRVideo_VideoStatusChanged.callback = (UID, oldStatus, newStatus) => {
        this.memberVideoStatusChange(UID, oldStatus, newStatus);
      };
      // SDK接口：通知 成员的默认摄像头变化
      CRVideo_DefVideoChanged.callback = (UID, defaultCam) => {
        // this.memberVideoDevChange(UID);
      };
      // SDK接口：通知 打开摄像头失败
      CRVideo_OpenVideoFailed.callback = (errCode, errDesc, videoID) => {
        this.openVideoFailed(errCode, errDesc, videoID);
      };
    }
    // 更新摄像头信息并展示
    updateVideoDevices() {
      // SDK接口：获取成员的默认摄像头
      const defaultVideoID = window.CRVideo_GetDefaultVideo(MeetingDemo.Login.userID);
      // SDK接口：获取成员的所有摄像头
      const videoList = window.CRVideo_GetAllVideoInfo(MeetingDemo.Login.userID);
      let optionStr = '';
      for (let i = 0; i < videoList.length; i++) {
        if (defaultVideoID == videoList[i].videoID) {
          optionStr += `<option value=\"${videoList[i].videoID}\" selected=\"selected\">${videoList[i].videoName}</option>`;
        } else {
          optionStr += `<option value=\"${videoList[i].videoID}\">${videoList[i].videoName}</option>`;
        }
      }
      // console.log(optionStr);
      $('#select_cam').html(optionStr);
    }
    // 打开用户的摄像头
    openVideo(UID) {
      // SDK接口：打开某个用户的摄像头
      CRVideo_OpenVideo(UID);
    }
    // 成员摄像头设备变化
    memberVideoDevChange(UID) {
      console.crlog(`[MeetingDemo] ${UID} 摄像头设备变化`);
      MeetingDemo.MemberMgr.members.forEach((item) => {
        if (item.userID == UID) {
          const allVideoInfo = window.CRVideo_GetAllVideoInfo(UID);
          const openedCams = window.CRVideo_GetOpenedVideoIDs(UID);
          if (openedCams.length !== item.allVideos.length) {
            // 数量有变化，得刷新视频墙
            this.refreshUserVideoWall(MeetingDemo.Video.curVideoPage);
            // 判断是自己的摄像头，则更新录制参数（更新方法里面判断是否正在单流录制中）
            if (UID == MeetingDemo.Login.userID) {
              MeetingDemo.Mixer.updateUnaflowRecord('mp4', +$('input[name=subscribeVideos]:checked').val());
            }
          } else {
            // 数量没有变化，只需要重新setVideo即可
            for (let i = 0; i < item.allVideos.length; i++) {
              const openVideo = allVideoInfo.find((item) => item.videoID == openedCams[i]);
              item.allVideos[i].videoUI.setVideo(UID, openedCams[i]);
              item.allVideos[i].videoID = openVideo.videoID;
              item.allVideos[i].videoName = openVideo.videoName;
            }
          }
        }
      });
      MeetingDemo.Mixer.updateInterflowRecord();
      // 自己的摄像头，更新摄像头列表
      if (UID === MeetingDemo.Login.userID) {
        MeetingDemo.Video.updateVideoDevices();
      }
    }
    // 刷新视频墙
    refreshUserVideoWall(page = 0) {
      page = page < 0 ? 0 : page;
      console.crlog(`[MeetingDemo] 刷新视频墙 --->  page:${page}`);

      // 配置每个成员的视频UI组件
      MeetingDemo.MemberMgr.refreshAllmembersInfo(); // 刷新成员列表

      // 刷新需要显示的视频列表
      const allVideoArr = [];
      MeetingDemo.MemberMgr.members.length > 0 &&
        MeetingDemo.MemberMgr.members.forEach((member, index) => {
          this.updateMemberVideoUI(member); // 成员视频UI组件处理
          // 取出所有需要显示的视频
          member.allVideos.forEach((videoItem) => {
            allVideoArr.push({
              userID: videoItem.userID,
              videoID: videoItem.videoID,
              videoUI: videoItem.videoUI,
            });
          });
          setTimeout(() => {
            MeetingDemo.MemberMgr.refreshUserIconStatus(member.userID); // 刷新图标样式
          }, 200);
        });

      // 不允许翻到空白页
      if (page * this.pageVideoNum >= allVideoArr.length && page != 0) return MeetingDemo.Video.lastPage();

      // 找出本页this.pageVideoNum个视频
      const pageVideos = [];
      let isChanged = false;
      for (let i = 0 + page * this.pageVideoNum, j = 0; i < allVideoArr.length && j < this.pageVideoNum; i++) {
        // 查找当前页面的视频是否有变动（新增或者减少了）
        if (!this.curPageVideos[j] || this.curPageVideos[j].videoUI.id() !== allVideoArr[i].videoUI.id()) isChanged = true;
        j++;
        pageVideos.length <= this.pageVideoNum && pageVideos.push(allVideoArr[i]);
      }
      if (this.curPageVideos.length !== pageVideos.length) isChanged = true;

      // 没有显示在当前页面的视频，全部退订
      allVideoArr.forEach((videoItem) => {
        if (!pageVideos.find((item) => item.userID == videoItem.userID && item.videoID == videoItem.videoID)) videoItem.videoUI.setVideo(videoItem.userID, 0);
      });
      this.curPageVideos = pageVideos;
      MeetingDemo.refreshScreenSplit(); // 刷新分屏样式

      // 处理翻页按钮
      if (allVideoArr.length <= (page + 1) * this.pageVideoNum) {
        $('#nextPageBtn').addClass('disabled');
      } else {
        $('#nextPageBtn').removeClass('disabled');
      }
      if (page == 0) {
        $('#lastPageBtn').addClass('disabled');
      } else {
        $('#lastPageBtn').removeClass('disabled');
      }

      if (!isChanged) return; // 如果本页面的视频没有变化，则不要处理

      // 重置页面的9个容器
      for (var i = 0; i < 9; i++) {
        $('.page_screen').children().eq(i).html('待进入');
      }
      // 给页面的this.pageVideoNum个容器中一个一个放入视频
      for (let k = 0; k < pageVideos.length; k++) {
        for (var i = 0; i < 9; i++) {
          if ($('.page_screen').children().eq(i).html().indexOf('待进入') > -1) {
            // 重新订阅本页的所有视频
            pageVideos[k].videoUI.setVideo(pageVideos[k].userID, pageVideos[k].videoID);
            $('.page_screen').children().eq(i).html(pageVideos[k].videoUI.handler());
            break;
          }
        }
      }
      // 注册事件
      $('.deviceIcon').hover(
        (e) => {
          const text = $(e.currentTarget).data('title');
          $(e.currentTarget).parent().children('.deviceIconText').html(text);
        },
        (e) => {
          $(e.currentTarget).parent().children('.deviceIconText').html('');
        }
      );
    }
    // 成员视频UI组件处理
    updateMemberVideoUI(member) {
      const allVideoInfo = window.CRVideo_GetAllVideoInfo(member.userID); // SDK接口：获取成员的所有摄像头信息
      const openedIDs = window.CRVideo_GetOpenedVideoIDs(member.userID) || []; // SDK接口：获取成员的当前打开的摄像头id集合
      const openedVideos = allVideoInfo.filter((item) => openedIDs.includes(item.videoID)); // 从所有摄像头信息里过滤出打开的摄像头
      const videoUIs = []; //  可能有多个摄像头同时开启的情况，那就需要创建多个UI组件
      const newMemberAllVideos = [];
      if (member.allVideos) {
        // 如果是已经有了的，就更新一下，没有的就添加上去
        for (var i = 0; i < openedVideos.length; i++) {
          const videoItem = member.allVideos.find((item) => item.userID == openedVideos[i].userID && item.videoID == openedVideos[i].videoID);
          if (videoItem) videoItem.videoName = openedVideos[i].videoName;
          newMemberAllVideos.push(
            videoItem || {
              userID: openedVideos[i].userID,
              videoID: openedVideos[i].videoID,
              videoName: openedVideos[i].videoName,
            }
          );
        }
        // 将多余的组件销毁（比如从启用多摄像头变为不启用，多余的摄像头组件要销毁一下）
        for (var i = 0; i < member.allVideos.length; i++) {
          const videoItem = newMemberAllVideos.find((item) => item.userID == member.allVideos[i].userID && item.videoID == member.allVideos[i].videoID);
          if (!videoItem && member.allVideos[i].videoUI) member.allVideos[i].videoUI.destroy();
        }
        member.allVideos = newMemberAllVideos;
      } else {
        member.allVideos = openedVideos;
      }
      // 即使没有打开摄像头，也创建一个UI组件（以前只处理了本地摄像头，现在远端成员也这样处理）；
      // if (member.userID == MeetingDemo.Login.userID && member.allVideos.length == 0) {
      if (member.allVideos.length == 0) {
        member.allVideos.push({
          // userID: MeetingDemo.Login.userID,
          userID: member.userID,
          videoID: -1,
          videoName: '',
        });
      }
      member.allVideos.forEach((videoItem) => {
        if (!videoItem.videoUI) {
          let posterImg = './image/pc/meeting_be_closed.jpg'; // 视频没有流时的预览图
          const videoStyle = {
            // video标签的自定义样式
            objectFit: 'cover', //object-fit属性，cover表示裁剪显示
          };
          // SDK接口：创建成员视频UI组件
          let videoUI = window.CRVideo_CreatVideoObj({
            // 可以传一个属性对象，都是video标签支持的属性
            poster: posterImg,
            // style: videoStyle
          });
          videoUI.setVideo(member.userID, videoItem.videoID); // 订阅具体的摄像头id
          // videoUI.setVideo(member.userID, -1); //订阅默认摄像头
          videoUI.setNickNameStyle(this.nameStyle); // 设置昵称样式
          videoUI.dblClickFullScreen(1); // 设置video是否双击全屏
          videoUI.showVideoSize(MeetingDemo.Video.showVideoSize); // 设置是否显示视频尺寸
          let videoIDStr = '';
          if (openedIDs.length > 1) {
            videoIDStr = `-${videoItem.videoID}`;
          }
          // 设置昵称内容，比如：张三-1
          if (member.userID == MeetingDemo.Login.userID) {
            videoUI.setNickNameContent(`我${videoIDStr}`);
          } else {
            videoUI.setNickNameContent(`${member.nickname}${videoIDStr}`);
          }
          videoUIs.push(videoUI);
          videoItem.videoUI = videoUI;

          // 业务层可以往UI组件里面添加自定义内容，但不能修改组件内已有的dom
          const userIcon = MeetingDemo.MemberMgr.createUserIcon(member.userID, videoItem.videoID, videoUI.id());
          videoUI.handler().appendChild(userIcon); // 添加控制图标
        } else {
          videoUIs.push(videoItem.videoUI);
        }
      });

      return videoUIs;
    }
    // 成员视频状态变化
    memberVideoStatusChange(UID, oldStatus, newStatus) {
      let nickname = '';
      // 更新状态
      MeetingDemo.MemberMgr.members.forEach((memberItem) => {
        if (memberItem.userID == UID) {
          memberItem.videoStatus = newStatus;
          nickname = UID == MeetingDemo.Login.userID ? '我' : memberItem.nickname;
        }
      });
      // 更新状态图标
      MeetingDemo.MemberMgr.refreshUserIconStatus(UID);
      // // 弹框通知
      // if (newStatus == 3 && oldStatus == 2) { //打开
      //     !!nickname && MeetingDemo.tipLayer(`${nickname} 的摄像头已打开`, 1500);
      // } else if (oldStatus == 3 && newStatus == 2) {
      //     !!nickname && MeetingDemo.tipLayer(`${nickname} 的摄像头已关闭`, 1500);
      // }
      MeetingDemo.Mixer.updateInterflowRecord();
    }
    // 点击工具栏本地摄像头开关按钮
    onClickCamOnOffBtn(dom) {
      if ($('#openCamBtn').hasClass('disabled')) {
        MeetingDemo.tipLayer('操作太频繁啦');
        return;
      }
      $('#openCamBtn').addClass('disabled');
      setTimeout(() => {
        $('#openCamBtn').removeClass('disabled');
      }, 1000);
      const $deviceCam = $('[data-userid=' + MeetingDemo.Login.userID + '] .deviceCam');
      const vStatus = window.CRVideo_GetVideoStatus(MeetingDemo.Login.userID); // SDK接口：获取成员的视频状态
      console.crlog(`[MeetingDemo] 获取${MeetingDemo.Login.userID}的视频状态：${vStatus}`);
      if (vStatus == 1 || vStatus == 'VNULL') {
        MeetingDemo.tipLayer('没有可打开的视频设备');
      } else if (vStatus == 2 || vStatus == 0 || vStatus == 'VUNKNOWN' || vStatus == 'VCLOSE') {
        CRVideo_OpenVideo(MeetingDemo.Login.userID); // SDK接口：打开成员摄像头
      } else if (vStatus == 3 || vStatus == 'VOPEN') {
        CRVideo_CloseVideo(MeetingDemo.Login.userID); // SDK接口：关闭成员摄像头
        $('#openCamBtn').addClass('cam_open').removeClass('cam_close');
        $deviceCam.removeClass('deviceCamActive');
      }
    }
    // 点击成员状态图标里的摄像头图标
    onClickUserIconCam(dom) {
      const $this = $(dom);
      const UID = $this.parent().data('userid');
      const members = window.CRVideo_GetAllMembers(); // SDK接口：获取会议内所有成员信息
      members.forEach((item) => {
        let parsedID = MeetingDemo.MemberMgr.parseUserID(item.userID);
        if (parsedID == UID) {
          if ($this.hasClass('deviceCamActive')) {
            //当前为打开状态
            CRVideo_CloseVideo(item.userID); // SDK接口：关闭摄像头
            if (item.userID == MeetingDemo.Login.userID) {
              // 关闭时直接设置图标，开启时等通知来了再设置图标
              $this.removeClass('deviceCamActive');
              $('#openCamBtn').addClass('cam_open').removeClass('cam_close');
            }
          } else {
            //当前为关闭状态
            CRVideo_OpenVideo(item.userID); // SDK接口：打开摄像头
          }
        }
      });
    }
    // 点击成员状态图标里的拍照按钮
    onClickUserIconSave(dom) {
      const $this = $(dom);
      const parseUserID = $this.parent().data('userid');
      const uiid = $this.parent().data('uiid');
      MeetingDemo.MemberMgr.members.forEach((member) => {
        if (MeetingDemo.MemberMgr.parseUserID(member.userID) == parseUserID) {
          member.allVideos.forEach((videoItem) => {
            if (videoItem.videoUI && videoItem.videoUI.id() == uiid) {
              // 直接保存照片 -- savePic
              const Date = MeetingDemo.getDate();
              const picName = `${member.userID}-${videoItem.videoUI.getVideoID()}-${Date.year}-${Date.month}-${Date.day}-${Date.hour}-${Date.minute}-${Date.second}.png`;
              videoItem.videoUI.savePic(picName);

              // 展示照片 -- savePicToBase64
              const base64Src = videoItem.videoUI.savePicToBase64('png');
              const img = document.createElement('img'); // 图片显示容器
              img.src = base64Src;
              // img.width = videoItem.videoUI.handler().children[1].clientWidth;
              img.height = videoItem.videoUI.handler().children[1].clientHeight;
              img.style.position = 'absolute';
              img.style.left = '50%';
              img.style.top = '50%';
              img.style.transform = 'translate(-50%,-50%)';
              img.style.boxShadow = '0 0 8px 1px rgb(0,0,0,.4)';
              img.onclick = function (e) {
                e.stopPropagation(); //阻止事件冒泡
              };
              const div = document.createElement('div'); // 遮罩
              div.style.position = 'fixed';
              div.style.width = '100%';
              div.style.height = '100%';
              div.style.backgroundColor = 'rgb(0,0,0,.4)';
              div.style.top = '0';
              div.style.left = '0';
              div.style.zIndex = '999';
              div.onclick = function () {
                div.remove(document.body);
              };
              div.appendChild(img);
              document.body.appendChild(div);
            }
          });
        }
      });
    }
    // 创建大小流视频组件
    createSubStreamVideoUI() {
      const videoUI_large = window.CRVideo_CreatVideoObj(); // SDK接口：创建成员视频UI组件
      videoUI_large.dblClickFullScreen(1); // 设置video是否双击全屏
      videoUI_large.showVideoSize(true); // 设置video是否显示视频尺寸
      document.querySelector('#subStreamVideo1').innerHTML = '';
      document.querySelector('#subStreamVideo1').appendChild(videoUI_large.handler());
      this.videoUI_large = videoUI_large;
      const videoUI_small = window.CRVideo_CreatVideoObj(); // SDK接口：创建成员视频UI组件
      videoUI_small.dblClickFullScreen(1); // 设置video是否双击全屏
      videoUI_small.showVideoSize(true); // 设置video是否显示视频尺寸
      document.querySelector('#subStreamVideo2').innerHTML = '';
      document.querySelector('#subStreamVideo2').appendChild(videoUI_small.handler());
      this.videoUI_small = videoUI_small;
    }
    // 点击视频组件里面的观看大小流
    onClickWatchStream(dom) {
      const $this = $(dom);
      const parseUserID = $this.parent().data('userid');
      const uiid = $this.parent().data('uiid');
      MeetingDemo.MemberMgr.members.forEach((member) => {
        if (MeetingDemo.MemberMgr.parseUserID(member.userID) == parseUserID) {
          member.allVideos.forEach((videoItem) => {
            if (videoItem.videoUI && videoItem.videoUI.id() == uiid) {
              this.videoUI_large.setVideo(videoItem.userID, videoItem.videoID, 1);
              this.videoUI_small.setVideo(videoItem.userID, videoItem.videoID, 2);
              document.querySelector('.sub-stream-view').style.display = 'flex';
            }
          });
        }
      });
    }
    // 关闭大小流窗口
    closeSubStreamWindow() {
      document.querySelector('.sub-stream-view').style.display = 'none';
      this.videoUI_large.setVideo('', 0);
      this.videoUI_small.setVideo('', 0);
    }
    // 切换分辨率或帧率或比例
    setVideoConfig(obj) {
      // SDK接口：设置视频参数
      CRVideo_SetVideoCfg(obj).then((res) => {
        // MeetingDemo.tipLayer('设置成功');
      }).catch(err => {
        MeetingDemo.tipLayer(`设置失败：${err.errDesc}`);
      })
    }
    // 设置默认摄像头（切换摄像头）
    setDefaultVideo(camID) {
      CRVideo_SetDefaultVideo(MeetingDemo.Login.userID, camID); // SDK接口：设置默认摄像头
    }
    // 设置是否启用多摄像头
    setEnableMutiVideo() {
      if (!!$('#mutiCam').prop('checked')) {
        CRVideo_SetEnableMutiVideo(MeetingDemo.Login.userID, true); // SDK接口：设置是否启用多摄像头
      } else {
        CRVideo_SetEnableMutiVideo(MeetingDemo.Login.userID, false);
      }
    }
    // 设置分屏数
    setPageVideoNum(obj) {
      console.crlog(`[MeetingDemo] 切换分屏数：${obj.videoNum}`);
      this.pageVideoNum = obj.videoNum;
      MeetingDemo.Video.refreshUserVideoWall(); // 刷新视频墙
    }
    // 翻页 上一页
    lastPage(dom) {
      if ($(dom).hasClass('disabled')) return;
      this.curVideoPage--;
      this.refreshUserVideoWall(this.curVideoPage);
    }
    // 翻页 下一页
    nextPage(dom) {
      if ($(dom).hasClass('disabled')) return;
      this.curVideoPage++;
      this.refreshUserVideoWall(this.curVideoPage);
    }
    // 点击添加虚拟摄像头按钮（图片）
    onClickAddCanvasCamBtn(dom) {
      MeetingDemo.promptLayer(2, '请输入图片Url', '', (value) => {
        this.addCanvasCam('img', '虚拟摄像头（图片）', value);
      });
    }
    // 点击添加/移除桌面摄像头按钮
    onClickAddScreenCamBtn(dom) {
      if ($(dom).data('toggle') == 0) {
        this.addScreenCam();
      } else {
        this.removeScreenCam();
      }
    }
    // 点击添加网络摄像头按钮
    onClickAddIPCamBtn(dom) {
      MeetingDemo.promptLayer(2, '请输入网络摄像头url（只支持wss://协议，且只支持特定摄像头，因为不同摄像头获取stream的方法不同）', '', (value) => {
        // wss://192.168.5.163:8087/live/av0
        if (value.indexOf('wss://') != 0) return MeetingDemo.alertLayer('url格式不正确，请输入正确的url。（当前只支持 wss:// 协议的网络摄像头）', this.onClickAddCanvasCamBtn);
        this.addIPCam(value);
      });
    }
    // 添加网络摄像头（这里只支持特定的摄像头，不同摄像头获取stream的方法不一样）
    addIPCam(url) {
      let idx = ++this.ipCamCount;
      let videoEle = document.createElement('video');
      videoEle.muted = true;
      videoEle.volume = 0;
      videoEle.autoplay = true;
      videoEle.addEventListener('playing', addStreamCam);
      let g_Wfs = new Wfs();
      g_Wfs.attachMedia(videoEle, url);
      let waitingTimer = setTimeout(() => {
        MeetingDemo.alertLayer(
          '摄像头连接失败，如果摄像头url确认无误，可能是受浏览器安全策略限制无法直接访问ip地址。您点击『确定』按钮后，将打开浏览器安全访问确认页面，请在页面中点击“高级——继续前往”以授权网页访问摄像头ip地址。',
          openIpAddr
        );
      }, 1000);
      function openIpAddr() {
        window.open(`https://${url.split('//')[1].split('/')[0].split(':')[0]}`);
      }
      function addStreamCam() {
        clearTimeout(waitingTimer);
        videoEle.removeEventListener('playing', addStreamCam);
        let stream = videoEle.captureStream();
        let camName = `IP摄像头${idx}`;
        CRVideo_AddStreamCam(stream, camName);
        MeetingDemo.Video.updateVideoDevices();
        MeetingDemo.alertLayer(`网络摄像头：${camName} 添加成功，您现在可以使用了`);
      }
    }
    // 添加桌面摄像头
    addScreenCam() {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
        return MeetingDemo.tipLayer(`当前浏览器版本不支持获取屏幕内容！`);
      }
      const screenCfg = {
        audio: false,
        video: true,
      };
      // 获取桌面媒体流
      navigator.mediaDevices.getDisplayMedia(screenCfg).then(
        (stream) => {
          const videoID = window.CRVideo_AddStreamCam(stream, '桌面摄像头'); // SDK接口：添加webrtc媒体流摄像头
          this.screenCamID = videoID;
          this.screenStream = stream;
          this.updateVideoDevices(); // 更新摄像头列表下拉菜单
          CRVideo_SetDefaultVideo(MeetingDemo.Login.userID, videoID); // SDK接口：设置默认摄像头
          $('#addScreenCamBtn').data('toggle', 1).text('移除桌面摄像头');
          // 监听桌面摄像头流结束(用户点击工具条停止共享)
          stream.getTracks()[0].onended = (e) => {
            this.removeScreenCam(); // 移除桌面摄像头
          };
        },
        (err) => {
          MeetingDemo.tipLayer(`获取桌面媒体流失败：${err}`);
        }
      );
    }
    // 移除桌面摄像头
    removeScreenCam() {
      const allVideo = window.CRVideo_GetAllVideoInfo(MeetingDemo.Login.userID);
      if (allVideo.length <= 1 && this.screenCamID) {
        // 本身没有其他摄像头，只有一个桌面摄像头
        window.CRVideo_CloseVideo(MeetingDemo.Login.userID); // SDK接口：关闭摄像头
      } else {
        // 如果当前的默认摄像头就是桌面摄像头，应先切换到其它摄像头
        const defVideoID = window.CRVideo_GetDefaultVideo(MeetingDemo.Login.userID); // SDK接口：获取默认摄像头ID
        defVideoID == this.screenCamID && window.CRVideo_SetDefaultVideo(MeetingDemo.Login.userID, allVideo[0].videoID); // SDK接口：设置默认摄像头
      }
      this.screenCamID && window.CRVideo_RemoveStreamVideo(this.screenCamID); // SDK接口：移除webrtc媒体流摄像头
      this.updateVideoDevices(); // 更新摄像头列表下拉菜单
      $('#addScreenCamBtn').data('toggle', 0).text('添加桌面摄像头');
      this.screenStream && this.screenStream.getTracks()[0].stop(); // 停止桌面媒体流
    }
    // 添加canvas虚拟摄像头
    addCanvasCam(type, name, url) {
      console.crlog(`[MeetingDemo] addCanvasCam：${type},${name},${url}`);
      if (type == 'img') {
        const _canvas = document.createElement('canvas');
        const _ctx = _canvas.getContext('2d');
        const _img = new Image();

        this.vCamInfo.url = url;
        this.vCamInfo.type = type;
        this.vCamInfo.canvas = _canvas;
        this.vCamInfo.ctx = _ctx;

        _img.src = url;
        _img.crossOrigin = 'anonymous';
        _img.onload = () => {
          _canvas.width = _img.width;
          _canvas.height = _img.height;

          // canvas上要有东西才会有画面，这里绘制这张图片到canvas上作为摄像头画面
          this._drawImage && this._drawImage();

          // 注意要先给canvas绘制一些，再添加为摄像头
          const CRVideo_VideoInfoObj = window.CRVideo_AddCanvasVCam(_canvas, name); // SDK接口：添加canvas摄像头
          this.vCamInfo.camNo = CRVideo_VideoInfoObj.videoID;
          this.updateVideoDevices(); // 更新摄像头列表
        };

        this._drawImage = () => {
          _ctx.drawImage(_img, 0, 0, _img.width, _img.height);
        };
      }
    }
    // 移除canvas虚拟摄像头
    removeCanvasCam(videoID) {
      if (!videoID) {
        videoID = this.vCamInfo.camNo;
        this.vCamInfo.camNo = 0;
      }
      videoID && window.CRVideo_RemoveCanvasVCam(videoID); // SDK接口：移除虚拟摄像头
    }
    // 点击选择虚拟背景图片
    chooseVBImg(dom) {
      if (type != 0 && $('#mutiCam')[0].checked == true) {
        MeetingDemo.tipLayer('多摄像头模式下虚拟背景将不可用');
        return;
      }

      const $dom = $(dom);

      $dom.addClass('active').siblings().removeClass('active');
      var type = $dom.data('type'),
        color,
        image;
      if (type == 1) {
        color = $dom.data('color');
      } else if (type == 2) {
        image = $dom.find('img')[0];
      }

      const sdkErr = window.CRVideo_SetVirtualBackground({
        type,
        color,
        image,
        blurIntensity: +$('#blurIntensitySlider').val(),
        // debuggerStyle: {
        //   position: 'absolute',
        //   right: '0px',
        //   bottom: '0px',
        //   width: '200px',
        //   height: '112px',
        //   zIndex: 9999,
        // }
      });
      if (sdkErr == 0) {
        $('#mutiCam').attr('disabled', type !== 0);
      } else if (sdkErr == 806) {
        MeetingDemo.tipLayer(`虚拟背景没有开启权限，请联系商务！`);
      }
    }
    // 虚拟背景选择界面取消按钮
    onClickVBCloseBtn() {
      $('.bgimg-choose').hide();

      window.CRVideo_SetVirtualBackground({
        type: 0,
      });
      $('#mutiCam').attr('disabled', false);
      $('.choose-list li').removeClass('active');
    }
    onBlurIntensitySliderChange(dom) {
      window.CRVideo_SetVirtualBackground({
        blurIntensity: +dom.value,
      });
    }
    // 打开摄像头失败
    openVideoFailed(errCode, err, videoID) {
      const camName = CRVideo_GetAllVideoInfo(MeetingDemo.Login.userID).find((item) => item.videoID == videoID).videoName;
      const videoStr = videoID ? ` ${videoID} :“${camName}”` : '';
      MeetingDemo.alertLayer(`打开摄像头${videoStr}失败，${err} </br>您的摄像头设备可能被占用或未授权访问，请检查后重新开关摄像头再试！`);
    }
    // 设置是否显示视频尺寸
    clickIsShowVideoSize() {
      let bool = !!$('#showVideSize').prop('checked');
      this.showVideoSize = bool;
      MeetingDemo.MemberMgr.members.forEach((member, index) => {
        member.allVideos.forEach((videoItem) => {
          videoItem.videoUI.showVideoSize(bool);
        });
      });
    }
    // 邀请监控设备
    inviteNetCam() {
      const url = $('#netcamUrl').val();
      const userID = $('#netcamUserId').val();
      const nickName = $('#netcamNickname').val();
      console.log(url, userID, nickName);
      if (url == '' || userID == '' || nickName == '') {
        MeetingDemo.tipLayer('请填写完整信息');
        return;
      }
      const usrExtDat = {
        meeting: { ID: MeetingDemo.RoomMgr.meetID },
        devInfo: {
          userID,
          nickName,
        },
      };

      CRVideo_Invite(url, JSON.stringify(usrExtDat));
      $('.invite-netcam-panel').hide();
    }
  }
  MeetingDemo.Video = new _videoM();

  // 音频管理模块
  class _audioM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      // this.curMic = null; // 当前正在使用的麦克风ID
      // this.curSpeaker = null; // 当前正在使用的扬声器ID
    }
    registerCallback() {
      // SDK接口：通知 成员麦克风状态改变
      CRVideo_AudioStatusChanged.callback = (UID, oldStatus, newStatus) => {
        this.memberAudioStatusChanged(UID, oldStatus, newStatus);
      };
      // SDK接口：通知 成员语音能量变化
      CRVideo_MicEnergyUpdate.callback = (userID, oldLevel, newLevel) => {
        this.memberMicEnergyUpdate(userID, oldLevel, newLevel);
      };
      // SDK接口：通知 打开麦克风失败
      CRVideo_OpenMicFailed.callback = (errCode, errDesc) => {
        this.openMicFailed(errDesc);
      };
      // SDK接口：通知 扬声器设备列表变化
      CRVideo_SpkDeviceChanged.callback = () => {
        this.updateAudioDevices();
      };
      // SDK接口：通知 麦克风设备列表变化
      CRVideo_MicDeviceChanged.callback = () => {
        this.updateAudioDevices();
      };
    }
    // 更新音频设备列表并展示
    updateAudioDevices() {
      const audioCfg = window.CRVideo_GetAudioCfg(); // SDK接口：获取当前音频设备参数
      const micArr = window.CRVideo_GetAudioMicNames(); // SDK接口：获取所有麦克风信息
      const spkerArr = window.CRVideo_GetAudioSpkNames(); // SDK接口：获取所有扬声器信息

      // 麦克风
      let micArrOptionsStr = '';
      for (let i = 0; i < micArr.length; i++) {
        if (audioCfg.micID == micArr[i].micID) {
          micArrOptionsStr += `<option value="${micArr[i].micID}" selected="true">${micArr[i].micName}</option>`;
        } else {
          micArrOptionsStr += `<option value="${micArr[i].micID}">${micArr[i].micName}</option>`;
        }
      }
      $('#select_mic').html(micArrOptionsStr);
      // this.curMic = $("#select_mic").val();

      // 扬声器
      let spkerArrOptionsStr = '';
      for (let i = 0; i < spkerArr.length; i++) {
        if (audioCfg.speakerID == spkerArr[i].speakerID) {
          spkerArrOptionsStr += `<option value="${spkerArr[i].speakerID}" selected=true>${spkerArr[i].speakerName}</option>`;
        } else {
          spkerArrOptionsStr += `<option value="${spkerArr[i].speakerID}">${spkerArr[i].speakerName}</option>`;
        }
      }
      $('#select_speaker').html(spkerArrOptionsStr);
      // this.curSpeaker = $("#select_speaker").val();
    }
    // 打开用户的麦克风
    openMic(UID) {
      CRVideo_OpenMic(UID); // SDK接口：打开某个用户的麦克风
    }
    // 成员音频状态变化
    memberAudioStatusChanged(UID, oldStatus, newStatus) {
      let nickname = '';
      // 更新状态
      MeetingDemo.MemberMgr.members.forEach((memberItem) => {
        if (memberItem.userID == UID) {
          memberItem.audioStatus = newStatus;
          nickname = UID == MeetingDemo.Login.userID ? '我' : memberItem.nickname;
        }
      });
      // 更新图标
      MeetingDemo.MemberMgr.refreshUserIconStatus(UID);
      // // 弹框通知
      // if (newStatus == 3 && oldStatus == 2) {
      //     !!nickname && MeetingDemo.tipLayer(`${nickname} 的麦克风已打开`, 1500);
      // } else if (newStatus == 2 && oldStatus == 3) {
      //     !!nickname && MeetingDemo.tipLayer(`${nickname} 的麦克风已关闭`, 1500);
      // }
    }
    // 成员语音能量变化
    memberMicEnergyUpdate(UID, oldLevel, newLevel) {
      // if(UID == MeetingDemo.Login.userID) console.log(newLevel);
      let parsedID = MeetingDemo.MemberMgr.parseUserID(UID);
      let $deviceMic = $('[data-userid=' + parsedID + '] .deviceMic');
      if (newLevel == 0) {
        clearTimeout(this.micEnergyRestTimer);
        this.micEnergyRestTimer = setTimeout(() => {
          $deviceMic.removeClass('deviceMicEnergy');
        }, 500);
      } else {
        $deviceMic.addClass('deviceMicEnergy');
      }
    }
    // 点击工具栏本地麦克风开关按钮
    onClickMicOnOffBtn(dom) {
      const $deviceMic = $('[data-userid=' + MeetingDemo.Login.userID + '] .deviceMic');
      const aStatus = window.CRVideo_GetAudioStatus(MeetingDemo.Login.userID); // SDK接口：获取成员的麦克风状态
      if (aStatus == 1) {
        // 1: ANULL  没有麦克风
        return MeetingDemo.tipLayer('没有可打开的音频设备');
      } else if (aStatus == 2 || aStatus == 0) {
        // 0: AUNKNOWN 2:ACLOSE  麦克风状态为未知或关闭
        CRVideo_OpenMic(MeetingDemo.Login.userID); // SDK接口：打开麦克风
      } else if (aStatus == 3) {
        // 3：AOPEN  麦克风状态为开启
        CRVideo_CloseMic(MeetingDemo.Login.userID); // SDK接口：关闭麦克风
        $('#openMicBtn').addClass('mic_close').removeClass('mic_open');
        $deviceMic.removeClass('deviceMicActive');
      }
    }
    // 点击工具栏扬声器播放/暂停按钮
    onClickSpeakerOnOffBtn(dom) {
      if ($('#openSpeakerBtn').hasClass('speaker_open')) {
        CRVideo_PauseSpeaker();
        $('#openSpeakerBtn').addClass('speaker_close').removeClass('speaker_open');
      } else {
        CRVideo_PlaySpeaker();
        $('#openSpeakerBtn').addClass('speaker_open').removeClass('speaker_close');
      }
    }
    // 点击成员状态图标里面的麦克风按钮
    onClickUserIconMic(dom) {
      const $this = $(dom);
      const UID = $this.parent().data('userid');
      const members = window.CRVideo_GetAllMembers(); // SDK接口：获取会议内所有成员信息
      members.forEach((item) => {
        let parsedID = MeetingDemo.MemberMgr.parseUserID(item.userID);
        if (parsedID == UID) {
          if ($this.hasClass('deviceMicActive')) {
            //当前为打开状态
            CRVideo_CloseMic(item.userID); // SDK接口：关闭麦克风
            if (item.userID == MeetingDemo.Login.userID) {
              // 关闭时直接设置图标，开启时等通知来了再设置图标
              $this.removeClass('deviceMicActive');
              $('#openMicBtn').addClass('mic_close').removeClass('mic_open');
            }
          } else {
            //当前为关闭状态
            CRVideo_OpenMic(item.userID); // SDK接口：打开麦克风
          }
        }
      });
    }
    // 设置音频参数（切换扬声器或麦克风）
    setAudioCongfig(cfg) {
      CRVideo_SetAudioCfg(cfg); // SDK接口：设置音频参数
    }
    // 点击全体静音按钮
    onClickCloseAll() {
      CRVideo_SetAllAudioClose(); // SDK接口：关闭房间内所有人麦克风
    }
    // 自动增益
    setAutoGainControl() {
      if (!!$('#autoGainControl').prop('checked')) {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          autoGainControl: true,
        });
        $('.mic-volume').hide();
      } else {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          autoGainControl: false,
        });
        const audioCfg = CRVideo_GetAudioCfg();
        $('#micVolInput').val(audioCfg.micVolume);
        $('#micVolStr').html(audioCfg.micVolume);
        $('.mic-volume').show();
      }
    }
    // 回声消除
    setEchoCancellation() {
      if (!!$('#echoCancellation').prop('checked')) {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          echoCancellation: true,
        });
      } else {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          echoCancellation: false,
        });
      }
    }
    // 噪声消除
    setNoiseSuppression() {
      if (!!$('#noiseSuppression').prop('checked')) {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          noiseSuppression: true,
        });
      } else {
        // SDK接口：设置音频参数
        CRVideo_SetAudioCfg({
          noiseSuppression: false,
        });
      }
    }
    // 设置麦克风音量
    setMicVol(ele) {
      const vol = +ele.value;
      $('#micVolStr').html(vol);
      CRVideo_SetAudioCfg({
        micVolume: vol,
      });
    }
    // 打开麦克风失败
    openMicFailed(err) {
      MeetingDemo.alertLayer(`打开麦克风失败：${err} </br>您的麦克风设备可能被占用或未授权访问，请检查后重新开关麦克风再试！`);
    }
  }
  MeetingDemo.Audio = new _audioM();

  // 屏幕共享模块
  class _screenM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.isStarting = false; // 是否正在启动中
      this.isSharing = false; // 是否正在共享中
      this.isMySharing = false; // 当前是否是我在共享
      this.screenShareUI = null;
      this.isRegionShare = false; // 是否区域共享
      this.screenFPS = 8; // 帧率
      // this.maxKbps = 6000; // 最大码率
      $('#openScreenBtn').removeClass('sharing');
      $('#openScreenBtn').removeClass('other-sharing');
      $('.page_share_box').hide().html('等待成员开启共享 ...');
    }
    registerCallback() {
      // SDK接口：通知 房间中开启了屏幕共享
      CRVideo_NotifyScreenShareStarted.callback = (sharer) => {
        $('#startMarkBtn').html('开启标注').addClass('disabled');
        setTimeout(() => {
          $('#startMarkBtn').removeClass('disabled');
        }, 2000);
        if (MeetingDemo.Media.isPlaying) MeetingDemo.Media.onClickStopMediaBtn(); // 如果当前在播放影音(本地)，则停止播放
        this.isSharing = true;
        this.isStarting = false;
        if (sharer == MeetingDemo.Login.userID) {
          this.isMySharing = true;
          $('#openScreenBtn').addClass('sharing');
          $('#stopScreenShareBtn').removeClass('disabled');
        } else {
          $('#stopScreenShareBtn').addClass('disabled');
          $('#openScreenBtn').addClass('other-sharing');
          $('.page_meet_video').hide();
          $('.page_share_box').show();
          MeetingDemo.Sync.switchToPage(6);
        }
        if (this.screenShareUI && this.screenShareUI.destroy) this.screenShareUI.destroy();
        this.screenShareUI = window.CRVideo_CreatScreenShareObj({
          poster: './image/pc/meeting_get_screen.jpg',
        });
        this.screenShareUI.setVideo(sharer);
        this.screenShareUI.setNickNameStyle(MeetingDemo.Video.nameStyle); // 设置昵称样式
        this.screenShareUI.setNickNameContent(CRVideo_GetMemberNickName(sharer) + '的屏幕');
        this.screenShareUI.dblClickFullScreen(1); // 设置双击全屏

        $('.page_share_box').html(this.screenShareUI.handler());
        MeetingDemo.Mixer.updateInterflowRecord(); // 更新云端录制内容

        MeetingDemo.exitFullscreen();
      };
      // SDK接口：通知 房间内屏幕共享结束
      CRVideo_NotifyScreenShareStopped.callback = (sharer) => {
        $('#startMarkBtn').html('开启标注');
        $('#stopScreenShareBtn').removeClass('disabled');
        this.onScreenShareStoped();
        if (sharer == MeetingDemo.Login.userID) {
          this.isMySharing = false;
          MeetingDemo.Sync.switchToPage(8);
          MeetingDemo.Mixer.updateInterflowRecord(); // 更新云端录制内容
        }
      };
      // SDK接口：通知 屏幕共享标注开始
      CRVideo_NotifyScreenMarkStarted.callback = (userID) => {
        $('#startMarkBtn').html('结束标注');
        $('.page_meet_video').hide();
        $('.page_share_box').show();
        MeetingDemo.Sync.switchToPage(6);
        // SDK接口：设置屏幕共享UI组件标注样式
        MeetingDemo.Screen.screenShareUI.setMark({
          allowMark: true,
          strokeStyle: '#ff0000', // 画笔颜色
          lineWidth: 3, // 画笔线宽
          cursor: 'url("./image/pc/meeting_pen1_.ico"), auto', // 画笔样式
        });
      };
      // SDK接口：通知 屏幕共享标注结束
      CRVideo_NotifyScreenMarkStopped.callback = (userID) => {
        $('#startMarkBtn').html('开启标注');
        // SDK接口：设置屏幕共享UI组件标注样式
        MeetingDemo.Screen.screenShareUI.setMark({
          allowMark: true,
          cursor: 'default', // 画笔样式
        });
      };
      // SDK接口：回调 开启屏幕共享结果
      CRVideo_StartScreenShareRslt.callback = (sdkErr) => {
        if (sdkErr == 0) {
          MeetingDemo.tipLayer(`当前正在共享自己的屏幕`);
        } else if (sdkErr == 700) {
          MeetingDemo.tipLayer(`共享失败，房间当前已在屏幕共享中！`);
        } else {
          this.isStarting = false;
          this.isSharing = false;
          this.isMySharing = false;
          $('.page_meet_video').show();
          $('.page_share_box').hide().html('等待成员开启共享 ...');
          MeetingDemo.Sync.switchToPage(8);
          if (sdkErr == 8002) {
            MeetingDemo.tipLayer(`开启屏幕共享失败，用户拒绝授予屏幕权限！`);
          } else if (sdkErr == 8004) {
            MeetingDemo.tipLayer(`开启屏幕共享失败，浏览器不支持获取屏幕！`);
          } else {
            MeetingDemo.tipLayer(`开启屏幕共享失败! 错误码：${sdkErr}`);
          }
        }
      };
    }
    // 选择是否区域共享
    regionShare(dom) {
      this.isRegionShare = dom.checked;
      // if (MeetingDemo.Screen.isMySharing) this.catchRectChange();
      this.catchRectChange();
    }
    // 共享修改共享区域
    catchRectChange(dom) {
      if (this.isRegionShare) {
        // SDK接口：设置屏幕共享参数
        CRVideo_SetScreenShareCfg({
          catchRect: {
            left: +$('#regShareLeft').val() || 0,
            top: +$('#regShareTop').val() || 0,
            width: +$('#regShareWidth').val() || 0,
            height: +$('#regShareHeight').val() || 0,
          },
          maxFPS: this.screenFPS,
        });
      } else {
        // SDK接口：设置屏幕共享参数
        CRVideo_SetScreenShareCfg({
          catchRect: null,
          maxFPS: this.screenFPS,
        });
      }
    }
    // 点击屏幕共享按钮
    onClickScreenShareBtn(dom) {
      if (MeetingDemo.Media.isStarting || MeetingDemo.Media.isPlaying) {
        // 当前没有在播放影音
        MeetingDemo.tipLayer(`当前房间正在播放影音，不可以共享屏幕！`);
        return;
      } else if (this.isSharing) {
        // 当前在屏幕共享中
        if ($('.page_share_box').css('display') == 'none') {
          $('.page_share_box').show();
          $('.page_meet_video').hide();
          MeetingDemo.Sync.switchToPage(6);
        } else {
          $('.page_share_box').hide();
          $('.page_meet_video').show();
          MeetingDemo.Sync.switchToPage(8);
        }
      } else {
        // 当前没有在屏幕共享或播放影音

        CRVideo_SetScreenShareCfg({
          maxFPS: this.screenFPS,
        });

        CRVideo_StartScreenShare(); // SDK接口：开始屏幕共享
        this.isStarting = true;
      }
    }
    // 点击开启标注按钮
    onClickStartMarkBtn(e) {
      if ($('#startMarkBtn').html().indexOf('开启标注') > -1) {
        console.crlog(`[MeetingDemo] 点击开启标注按钮`);
        CRVideo_StartScreenMark(); // SDK接口：开始屏幕标注
        $('#startMarkBtn').html('结束标注');
        $('.page_meet_video').hide();
        $('.page_share_box').show();
        MeetingDemo.Sync.switchToPage(6);
      } else {
        console.crlog(`[MeetingDemo] 点击关闭标注按钮`);
        CRVideo_StopScreenMark(); // SDK接口：停止屏幕标注
        $('#startMarkBtn').html('开启标注');
      }
      e && e.stopPropagation();
      return false;
    }
    // 点击结束共享按钮
    onClickStopScreenShareBtn(e) {
      console.crlog(`[MeetingDemo] 点击结束共享按钮`);
      e && e.stopPropagation();
      if (this.isSharing && this.isMySharing) {
        CRVideo_StopScreenShare(); // SDK接口：结束屏幕共享
      }
      return false;
    }
    // 屏幕共享结束后的处理
    onScreenShareStoped() {
      MeetingDemo.exitFullscreen();
      this.isSharing = false;
      this.isMySharing = false;
      $('#openScreenBtn').removeClass('sharing');
      $('#openScreenBtn').removeClass('other-sharing');
      $('.page_meet_video').show();
      $('.page_share_box').hide().html('等待成员开启共享 ...');
    }
  }
  MeetingDemo.Screen = new _screenM();

  // 影音共享模块
  class _mediaM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.mediaShareUIObj = null;
      this.isStarting = false;
      this.isPlaying = false;
      this.isMyPlaying = false;
    }
    registerCallback() {
      // SDK接口：通知 房间内开始播放影音
      CRVideo_NotifyMediaStart.callback = (UID) => {
        this.isPlaying = true;
        this.isStarting = false;
        if (UID == MeetingDemo.Login.userID) {
          $('#openMediaBtn').addClass('playing');
          this.isMyPlaying = true;
        } else {
          this.mediaShareUIObj = window.CRVideo_CreatMediaObj();
          this.mediaShareUIObj.setVideo(UID);
          this.mediaShareUIObj.setNickNameStyle(MeetingDemo.Video.nameStyle); // 设置昵称样式
          this.mediaShareUIObj.setNickNameContent(CRVideo_GetMemberNickName(UID) + '播放的影音');
          this.mediaShareUIObj.dblClickFullScreen(1); // 设置双击全屏
        }

        $('.page_share_box').html(this.mediaShareUIObj.handler());
        $('.page_meet_video').hide();
        $('.page_share_box').show();
        MeetingDemo.Sync.switchToPage(7);
        MeetingDemo.Mixer.updateInterflowRecord(); // 更新云端录制内容

        MeetingDemo.exitFullscreen();
      };
      // SDK接口：通知 房间内影音播放停止
      CRVideo_NotifyMediaStop.callback = (UID) => {
        this.stopPlayingHandler();
        MeetingDemo.Mixer.updateInterflowRecord(); // 更新云端录制内容
      };
    }
    // 点击影音共享按钮
    onClickMediaShareBtn() {
      console.crlog(`[MeetingDemo] 点击影音共享按钮影音共享`);
      if (MeetingDemo.Screen.isSharing) {
        MeetingDemo.tipLayer(`当前房间正在屏幕共享中，不可同时共享影音！`);
        return;
      } else if (this.isPlaying) {
        if ($('.page_share_box').css('display') == 'none') {
          $('.page_share_box').show();
          $('.page_meet_video').hide();
          MeetingDemo.Sync.switchToPage(7);
        } else {
          $('.page_share_box').hide();
          $('.page_meet_video').show();
          MeetingDemo.Sync.switchToPage(8);
        }
      } else {
        // SDK接口：创建影音共享UI组件
        this.mediaShareUIObj = window.CRVideo_CreatMediaObj();
        this.mediaShareUIObj.dblClickFullScreen(1); // 设置双击全屏

        // $('.page_share_box').html(this.mediaShareUIObj.handler());

        var evt = new MouseEvent('click', {
          bubbles: false,
          cancelable: true,
          view: window,
        });
        $('#mediaFileInput')[0].dispatchEvent(evt);
      }
    }
    // 载入影音文件
    onLoadMediaFiles(dom) {
      if (MeetingDemo.Screen.isSharing) {
        MeetingDemo.tipLayer(`房间当前正在屏幕共享中，不可同时共享影音！`);
        $('#openMediaBtn').removeClass('playing');
        $('#mediaFileInput')[0].value = null;
        this.mediaShareUIObj = null;
        this.mediaShareUIObj = null;
        this.isStarting = false;
        this.isPlaying = false;
        this.isMyPlaying = false;
        return;
      } else if (this.isPlaying) {
        MeetingDemo.tipLayer(`共享失败，房间当前已在影音共享中！`);
        $('.page_share_box').show();
        $('.page_meet_video').hide();
      } else {
        const file = dom.files[0];
        $('.page_share_box').show();
        $('.page_meet_video').hide();
        MeetingDemo.Sync.switchToPage(7);
        this.isStarting = true;
        const isPlaying = window.CRVideo_StartPlayMedia(this.mediaShareUIObj, file, 0, 2); // SDK接口：开始播放影音
        if (!isPlaying) {
          MeetingDemo.tipLayer('不支持该影音格式！');
          this.stopPlayingHandler();
        }
      }
    }
    // 点击停止播放按钮
    onClickStopMediaBtn(e) {
      console.crlog(`[MeetingDemo] 点击停止播放按钮`);
      e && e.stopPropagation();
      if (this.isPlaying && this.isMyPlaying) {
        this.stopPlayingHandler();
        CRVideo_StopPlayMedia(); // SDK接口：结束屏幕共享
      }
      return false;
    }
    // 停止播放的处理
    stopPlayingHandler() {
      MeetingDemo.exitFullscreen();
      $('#openMediaBtn').removeClass('playing');
      $('.page_share_box').hide().html('等待成员开启共享 ...');
      $('.page_meet_video').show();
      MeetingDemo.Sync.switchToPage(8);
      $('#mediaFileInput')[0].value = null;
      this.mediaShareUIObj = null;
      this.isStarting = false;
      this.isPlaying = false;
      this.isMyPlaying = false;
    }
  }
  MeetingDemo.Media = new _mediaM();

  // 邀请模块
  class _inviteM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.inviteID = null;
      this.curLayerIndex = null;
    }
    // 注册SDK回调
    registerCallback() {
      // SDK接口：回调 发送邀请成功
      CRVideo_InviteSuccess.callback = (inviteID, cookie) => {
        console.crlog(`[MeetingDemo] 发送邀请成功：${inviteID}`);
        this.inviteID = inviteID;
        // this.curLayerIndex = layer.open({
        //     closeBtn: 0,
        //     title: [`邀请`, 'font-size:0.16rem'],
        //     content: `邀请发送成功，等待对方应答...`,
        //     btn: ['取消邀请'],
        //     btn1: function (index) {
        //         CRVideo_CancelInvite(inviteID, '', ''); // SDK接口：取消邀请
        //         window.layer.close(index);
        //     },
        // })
      };
      // SDK接口：回调 发送邀请失败
      CRVideo_InviteFail.callback = (inviteID, sdkErr, cookie) => {
        console.crlog(`[MeetingDemo] 发送邀请失败：${sdkErr}，${inviteID}`);
        this.inviteID = inviteID;
        MeetingDemo.alertLayer(`发送邀请失败：${sdkErr}`);
      };
      // SDK接口：回调 取消邀请成功
      CRVideo_CancelInviteSuccess.callback = (inviteID, cookie) => {
        MeetingDemo.tipLayer(`邀请已取消`);
      };
      // SDK接口：回调 取消邀请失败
      CRVideo_CancelInviteFail.callback = (inviteID, sdkErr, cookie) => {
        MeetingDemo.tipLayer(`取消邀请失败:${sdkErr}`);
      };
      // SDK接口：通知 我发送的邀请被对方接受
      CRVideo_NotifyInviteAccepted.callback = (inviteID, userExtDat) => {
        console.crlog(`[MeetingDemo] 对方接受邀请：${inviteID}，${userExtDat}`);
        window.layer.close(this.curLayerIndex);
        MeetingDemo.tipLayer(`对方已接受邀请，正在进入房间...`);
      };
      // SDK接口：通知 我发送的邀请被对方拒绝
      CRVideo_NotifyInviteRejected.callback = (inviteID, reason, userExtDat) => {
        console.crlog(`[MeetingDemo] 对方拒绝邀请：${inviteID}，${reason}，${userExtDat}`);
        window.layer.close(this.curLayerIndex);
        if (reason == '604') {
          MeetingDemo.alertLayer(`邀请失败，对方无应答！`);
        } else {
          MeetingDemo.alertLayer(`对方拒绝了本次邀请！`);
        }
      };
      // SDK接口：通知 收到别人的邀请
      CRVideo_NotifyInviteIn.callback = (inviteID, inviterUserID, userExtDat) => {
        console.crlog(`[MeetingDemo] 收到来自 ${inviterUserID} 的邀请：${userExtDat}，${inviteID}`);
        if (MeetingDemo.RoomMgr.isMeeting) {
          CRVideo_RejectInvite(inviteID, userExtDat, `用户 ${inviterUserID} 邀请你加入房间，当前正在房间中，已自动拒绝该邀请。`);
          return;
        }
        this.curLayerIndex = layer.open({
          closeBtn: 0,
          title: [`邀请`, 'font-size:0.16rem'],
          content: `用户 ${inviterUserID} 邀请你加入房间 ${userExtDat}，</br>是否接受邀请？`,
          btn: ['接受', '拒绝'],
          btn1: function (index) {
            CRVideo_AcceptInvite(inviteID, userExtDat, userExtDat);
            window.layer.close(index);
          },
          btn2: function (index) {
            CRVideo_RejectInvite(inviteID, userExtDat, userExtDat);
          },
        });
      };
      // SDK接口：通知 对方取消了邀请
      CRVideo_NotifyInviteCanceled.callback = (inviteID, reason, userExtDat) => {
        console.crlog(`[MeetingDemo] 对方取消邀请：${inviteID}，${reason}，${userExtDat}`);
        window.layer.close(this.curLayerIndex);
        MeetingDemo.tipLayer('对方取消了邀请！');
      };
      // SDK接口：回调 接受对方的邀请成功
      CRVideo_AcceptInviteSuccess.callback = (inviteID, cookie) => {
        console.crlog(`[MeetingDemo] 接受邀请成功：${inviteID}`);
        MeetingDemo.tipLayer(`接受邀请成功，进入房间：${JSON.parse(cookie).meeting.ID}`);
        MeetingDemo.RoomMgr.meetID = JSON.parse(cookie).meeting.ID;
        MeetingDemo.RoomMgr.enterMeetingFun();
      };
      // SDK接口：回调 接受对方的邀请失败
      CRVideo_AcceptInviteFail.callback = (inviteID, sdkErr, cookie) => {
        console.crlog(`[MeetingDemo] 接受邀请失败：${sdkErr}，${inviteID}`);
        MeetingDemo.tipLayer(`接受邀请失败：${sdkErr}，${inviteID}`);
      };
      // SDK接口：回调 拒绝对方的邀请成功
      CRVideo_RejectInviteSuccess.callback = (inviteID, cookie) => {
        console.crlog(`[MeetingDemo] 拒绝邀请成功：${inviteID}`);
        MeetingDemo.tipLayer(`已拒绝对方的邀请`);
      };
      // SDK接口：回调 拒绝对方的邀请失败
      CRVideo_RejectInviteFail.callback = (inviteID, sdkErr, cookie) => {
        console.crlog(`[MeetingDemo] 拒绝邀请失败：${sdkErr}，${inviteID}`);
        MeetingDemo.tipLayer(`拒绝邀请失败：${sdkErr}，${inviteID}`);
      };
    }
    // 点击邀请按钮
    openInviteBtn() {
      window.layer.prompt(
        {
          formType: 2,
          value: '',
          title: '请输入被邀请者的ID(多个用户请用；号隔开)',
          area: ['200px', '20px'], //自定义文本域宽高
        },
        function (value, index, elem) {
          const users = value.toString().split(';');
          for (let i = 0; i < users.length; i++) {
            // CRVideo_Invite(users[i], MeetingDemo.RoomMgr.meetID);
            MeetingDemo.Invite.sendInvite(users[i]);
          }
          window.layer.close(index);
        }
      );
    }
    // 发送邀请
    sendInvite(UID) {
      CRVideo_Invite(
        UID,
        JSON.stringify({
          meeting: {
            ID: MeetingDemo.RoomMgr.meetID,
          },
        })
      );
    }
  }
  MeetingDemo.Invite = new _inviteM();

  // 聊天模块
  class _chatM {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() { }
    registerCallback() {
      // SDK接口：回调 发送消息的结果
      CRVideo_SendMeetingCustomMsgRslt.callback = (errCode, cookie) => {
        if (errCode == 0) {
          //发送成功
          $('input[name=chat_msg]').val('');
        } else {
          MeetingDemo.tipLayer(`消息发送失败！${errCode}`);
        }
      };
      // SDK接口：通知 收到广播消息
      CRVideo_NotifyMeetingCustomMsg.callback = (fromUserID, stringMsg) => {
        let jsonMsg = {};
        try {
          jsonMsg = JSON.parse(stringMsg);
        } catch (e) {
          console.error(e);
        }
        if (jsonMsg.CmdType && jsonMsg.CmdType == 'IM') this.recivedChatMsg(fromUserID, jsonMsg.IMMsg);
      };
    }
    // 点击工具栏聊天按钮
    onClickChatBtn() {
      if ($('.page_meet_chat').css('display') == 'none') {
        $('.page_meet_chat').show();
        $('.page_chat_box').show();
      } else {
        $('.page_meet_chat').hide();
        $('.page_chat_box').hide();
      }
    }
    // 点击聊天发送按钮
    onClickSendBtn() {
      const msgText = $('input[name=chat_msg]').val();
      const stringMsg = JSON.stringify({
        CmdType: 'IM',
        IMMsg: msgText,
      });
      CRVideo_SendMeetingCustomMsg(stringMsg); // SDK接口：发送会议内广播消息
    }
    // 收到聊天消息
    recivedChatMsg(userID, textmsg) {
      const msg = textmsg;
      const nickname = window.CRVideo_GetMemberNickName(userID) || userID; // SDK接口：获取用户的昵称
      const htmlEle = `<li>
                        <span class="chat_content">
                            <span class="chat_name">${nickname}</span>：${msg}
                        </span>
                    </li>
                    </br>`;
      $('.page_chat_box > ul').append(htmlEle);
      $('.page_chat_box > ul')[0].scrollTop = $('.page_chat_box > ul')[0].scrollHeight; // 让滚动条自动滚动到底部

      if ($('.page_chat_box').css('display') == 'none') {
        MeetingDemo.tipLayer('收到了新的聊天消息...', 1000);
      }
    }
  }
  MeetingDemo.Chat = new _chatM();

  // 透明通道模块
  class _CMDClass {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() {
      this.sendFile = null;
      this.recivedFileData = null;
    }
    registerCallback() {
      // SDK接口：回调 发送点对点消息的结果
      CRVideo_SendCmdRslt.callback = (taskID, sdkErr, cookie) => {
        if (sdkErr == 0) {
          MeetingDemo.tipLayer('发送成功');
        } else {
          MeetingDemo.tipLayer(`发送失败！${sdkErr}`);
        }
      };
      // SDK接口：通知 发送进度
      CRVideo_SendProgress.callback = (taskID, sendedLen, totalLen, cookie) => {
        $('#fileSendBtn').html(`点击取消发送 ${parseInt((sendedLen / totalLen) * 100)}%`);
      };
      // SDK接口：通知 发送文件的结果
      CRVideo_SendFileRslt.callback = (uuid, sdkErr, cookie) => {
        $('#fileSendBtn').html(`发送`);
        if (sdkErr == 0) {
          MeetingDemo.tipLayer('发送完成！');
        } else if (sdkErr == 1199) {
          MeetingDemo.tipLayer('发送已取消！');
        } else {
          MeetingDemo.tipLayer(`文件发送失败！${sdkErr}`);
        }
      };
      // SDK接口：通知 收到小块数据
      CRVideo_NotifyCmdData.callback = (userID, data) => {
        $('#fromUserID').html(userID);
        $('#msgType').html('文本命令');
        let jsonData = null;
        try {
          jsonData = JSON.parse(data);
          if (jsonData.CmdType && jsonData.CmdType == 'IM') {
            data = jsonData.IMMsg;
          }
        } catch (e) { }
        $('#fromUserID').html(userID);
        $('#msgType').html('文本命令');
        $('#cmdValueBox').html(data);
        $('.open-channel-btn').hide();
        $('.data-channel .msg-box .recive .notify-cmd').show().siblings().hide();
        $('.data-channel .msg-box .recive').show();
        $('.data-channel .msg-box .send').hide();
        $('.data-channel .msg-box').show();
        $('.data-channel').show();
        $('#answerBtn').click(() => {
          $('.data-channel .msg-box .recive').hide();
          $('.data-channel .msg-box .send').show();
          $('.tab-cmd').click();
        });
      };
      // SDK接口： 通知 收到文件数据
      CRVideo_NotifyFileData.callback = (userID, fileBuffer, fileName) => {
        this.recivedFileData = fileBuffer;
        $('#fromUserID').html(userID);
        $('#msgType').html('文件数据');
        $('#fileNameBox').html(fileName);
        $('.open-channel-btn').hide();
        $('.data-channel .msg-box .recive .notify-file').show().siblings().hide();
        $('.data-channel .msg-box .recive').show();
        $('.data-channel .msg-box .send').hide();
        $('.data-channel .msg-box').show();
        $('.data-channel').show();
        $('#downloadBtn').click(() => {
          const blob = new Blob([fileBuffer]);
          const url = window.URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.style.display = 'none';
          a.href = url;
          a.download = fileName;
          document.body.appendChild(a);
          a.click();
        });
      };
      // SDK接口：通知 收到大块数据
      CRVideo_NotifyBufferData.callback = (userID, data) => {
        $('#fromUserID').html(userID);
        $('#msgType').html('大块数据');
        $('#bufferValueBox').html(data);
        $('.open-channel-btn').hide();
        $('.data-channel .msg-box .recive .notify-buffer').show().siblings().hide();
        $('.data-channel .msg-box .recive').show();
        $('.data-channel .msg-box .send').hide();
        $('.data-channel .msg-box').show();
        $('.data-channel').show();
      };
    }
    // 点击 透明通道 按钮
    onClickDataChannelBtn(dom) {
      $(dom).hide(100);
      $('.data-channel .msg-box .recive').hide();
      $('.data-channel .msg-box .send').show();
      $('.data-channel .msg-box').show();
      $('.data-channel').show(100);
    }
    // 点击 X
    onClickCloseBtn() {
      $('.data-channel').hide(100);
      setTimeout(() => {
        $('.open-channel-btn').show(100);
        $('.data-channel .msg-box').hide();
      }, 100);
    }
    // 点击tab栏
    onClickTabBtn(dom, tag) {
      $(dom).addClass('checked').siblings().removeClass('checked');
      if (tag == 'cmd') {
        $('.send .send-cmd').show();
        $('.send .send-file').hide();
      } else {
        $('.send .send-file').show();
        $('.send .send-cmd').hide();
      }
    }
    // 点击选择文件按钮
    onClickFileLoadBtn() {
      var evt = new MouseEvent('click', {
        bubbles: false,
        cancelable: true,
        view: window,
      });
      $('#fileInput')[0].dispatchEvent(evt);
    }
    // 载入文件
    onLoadFile(dom) {
      const file = dom.files[0];
      if (!file) return;
      this.sendFile = file;
      $('#sendFileInfo').html(file.name);
    }
    // 点击发送文件按钮
    onClickFileSendBtn(dom) {
      if ($(dom).html() == '发送') {
        const userID = $.trim($('#fileUserIDInput').val());
        if (!userID) {
          MeetingDemo.alertLayer('请输入目标用户的ID！');
          return;
        }
        if (!this.sendFile) {
          MeetingDemo.alertLayer('请先选择本地文件！');
          return;
        }
        this.sendTaskID = window.CRVideo_SendFile(userID, this.sendFile); // SDK接口：发送文件数据
      } else {
        CRVideo_CancelSend(this.sendTaskID); // SDK接口：取消数据发送
        $('#fileSendBtn').html(`发送`);
      }
    }
    // 点击发送命令按钮
    onClickCmdSendBtn() {
      const userID = $.trim($('#cmdUserIDInput').val());
      if (!userID) {
        MeetingDemo.alertLayer('请输入目标用户的ID！');
        return;
      }
      const msg = $('#cmdInputBox').val();
      if (!msg) {
        MeetingDemo.alertLayer('发送内容不能为空！');
        return;
      }
      const jsonMsg = JSON.stringify({
        CmdType: 'IM',
        IMMsg: msg,
      });
      CRVideo_SendCmd(userID, jsonMsg); // SDK接口：发送点对点消息
    }
  }
  MeetingDemo.CMD = new _CMDClass();

  // 界面同步
  class _SyncClass {
    constructor() {
      this.initData();
      this.registerCallback();
    }
    initData() { }
    registerCallback() { }
    // 切换功能区
    switchToPage(mainPage) {
      if (!MeetingDemo.RoomMgr.isMeeting) return;
      switch (mainPage) {
        case 6: // 屏幕共享
          // MeetingDemo.tipLayer(`当前主功能区：屏幕共享`);
          $('.page_share_box').show();
          $('.page_meet_video').hide();
          break;
        case 7: // 影音共享
          // MeetingDemo.tipLayer(`当前主功能区：影音共享`);
          $('.page_share_box').show();
          $('.page_meet_video').hide();
          break;
        case 8: // 视频墙
          // MeetingDemo.tipLayer(`当前主功能区：视频墙`);
          $('.page_meet_video').show();
          $('.page_share_box').hide();
          $('.page_meet_chat').show();
          $('.page_chat_box').show();
          break;
        default:
          break;
      }
    }
  }
  MeetingDemo.Sync = new _SyncClass();

  // 新云端录制模块
  class _CloudMixerClass {
    constructor() {
      this.initData();
      this.registerCallback();
      this.loadEvent();
    }
    initData() {
      this.allMixerInfo = [];

      //合流录制的配置
      this.interflowVideoCfg = {
        width: 1280,
        height: 720,
      };

      $('.file-info-list').html('');
      $('#unaflowRecordBtn').text('开始单流录制');
      $('#interflowRecordBtn').text('开始合流录制');
    }
    registerCallback() {
      // SDK接口：通知 某个云端录制混图器状态变化
      window.CRVideo_CloudMixerStateChanged.callback = (ID, status, exParam, userID) => {
        console.log(`云端录制状态变化：\r\nID:${ID}\r\nstatus:${status}\r\nexParam:${JSON.stringify(exParam)}\r\nuserID:${userID}`);
        if (status == 0) {
          if (exParam.err === 0) {
            MeetingDemo.tipLayer(`ID:${ID}，</br>录制已结束`);
          } else {
            MeetingDemo.tipLayer(`ID:${ID}，</br>开启录制失败，错误码: ${exParam.err},${exParam.errDesc}`);
          }
        } else if (status == 1) {
          MeetingDemo.tipLayer(`ID:${ID}，</br>录制启动中`);
        } else if (status == 2) {
          MeetingDemo.tipLayer(`ID:${ID}，</br>正在录制中`);
        }
        setTimeout(() => {
          this.getAllCloudMixerInfo();
        }, 0);
      };
      // SDK接口：通知 某个云端录制混图器信息变化
      window.CRVideo_CloudMixerInfoChanged.callback = (ID) => {
        console.log(`云端录制信息变化，ID:${ID}`);
        this.getAllCloudMixerInfo();
      };
      // SDK接口：通知 某个云端录制混图器输出变化
      window.CRVideo_CloudMixerOutputInfoChanged.callback = (ID, jsonState) => {
        let stateStr = '';
        switch (jsonState.state) {
          case 1:
            stateStr = '录制中';
            break;
          case 2:
            stateStr = '录制完成';
            break;
          case 3:
            stateStr = `录制出错！错误码：${jsonState.errCode},${jsonState.errDesc}`;
            break;
          case 4:
            stateStr = `正在上传，${Math.ceil(jsonState.progress)}%`;
            break;
          case 5:
            stateStr = '上传完成';
            break;
          case 6:
            stateStr = '上传失败';
            break;
          case 7:
            stateStr = '全部完成';
            this.getAllCloudMixerInfo();
            break;

          default:
            stateStr = jsonState.state;
            break;
        }
        $('.file-info-list').append(`<li>ID:${ID}，文件名:${jsonState.fileName}，状态:${stateStr}</li>`);
        $('.file-info-list')[0].scrollTop = $('.file-info-list')[0].scrollHeight;
      };
    }
    loadEvent() { }

    //点击了开始录制
    startRecord = (task) => {
      if (task === 'unaflowRecord') {
        if (this.myUnaflow && this.myUnaflow.state !== 0) {
          CRVideo_DestroyCloudMixer(this.myUnaflow.ID);
          this.myUnaflow = null;
          $('#unaflowRecordBtn').text('开始单流录制').prop('disabled', false);
        } else {
          this.createUnaflowMixer();
        }
      } else {
        if (this.myInterflow && this.myInterflow.state !== 0) {
          CRVideo_DestroyCloudMixer(this.myInterflow.ID);
          this.myInterflow = null;
          $('#interflowRecordBtn').text('开始合流录制').prop('disabled', false);
        } else {
          this.createInterflowMixer();
        }
      }
    };
    // 根据Type生成视频订阅的参数
    createSubscribeVideos(type) {
      return [
        ['_cr_all_'],
        ['_cr_allDefCam_'],
        (function () {
          var subscribeVideos = [];
          const myOpenedIDs = window.CRVideo_GetOpenedVideoIDs(MeetingDemo.Login.userID);
          myOpenedIDs.forEach((item) => {
            subscribeVideos.push(`${MeetingDemo.Login.userID}.${item}`);
          });
          return subscribeVideos;
        })(),
        [`${MeetingDemo.Login.userID}.-1`],
      ][type];
    }
    // 根据Type生成音频订阅的参数
    createSubscribeAudios(type) {
      return [[MeetingDemo.Login.userID], ['_cr_all_']][type];
    }
    //单流配置修改后，更新录制
    updateUnaflowRecord = (str, type) => {
      if (this.myUnaflow && this.myUnaflow.state === 2) {
        //如果原来有生成MP4文件，才更新
        if (str === 'mp4' && this.myUnaflow.cfg.videoFileCfg) {
          const json = {
            videoFileCfg: {
              subscribeVideos: this.createSubscribeVideos(type),
            },
          };
          CRVideo_UpdateCloudMixerContent(this.myUnaflow.ID, json);
        }

        //如果原来有生成MP3文件，才更新
        if (str === 'mp3' && this.myUnaflow.cfg.audioFileCfg) {
          const json = {
            audioFileCfg: {
              subscribeAudios: this.createSubscribeAudios(type),
            },
          };
          CRVideo_UpdateCloudMixerContent(this.myUnaflow.ID, json);
        }
      }
    };
    //更新合流录制
    updateInterflowRecord = () => {
      if (this.myInterflow && this.myInterflow.state === 2) {
        const json = {
          videoFileCfg: {
            layoutConfig: this.createLayoutConfig(),
          },
        };
        CRVideo_UpdateCloudMixerContent(this.myInterflow.ID, json);
      }
    };
    //获取第三方云盘信息
    updateThirdPartyCloud() {
      if (!$('#isUploadOss')[0].checked) return false;
      return {
        vendor: +$('#ossCloudPlatform').val(),
        region: $('#ossArea').val(),
        bucket: $('#ossBucket').val(),
        accessKey: $('#ossAccess').val(),
        secretKey: $('#ossSecret').val(),
      };
    }
    // 点击单流录制按钮
    createUnaflowMixer() {
      const isCreateMp3File = $('#isMp3File')[0].checked;
      const isCreateMp4File = $('#isMp4File')[0].checked;

      if (!isCreateMp3File && !isCreateMp4File) {
        MeetingDemo.tipLayer('至少需要录制一种格式的文件', 2000);
        return;
      }

      const jsonCfg = {
        mode: 1,
      };

      const ossCfg = this.updateThirdPartyCloud();
      if (ossCfg) {
        jsonCfg.storageConfig = ossCfg;
      }

      const { year, month, day, hour, minute, second } = MeetingDemo.getDate(),
        meetID = MeetingDemo.RoomMgr.meetID,
        svrPath = `/${year}-${month}-${day}/${year}-${month}-${day}_${hour}-${minute}-${second}_web_${meetID}_unaflow`;

      //如果需要生成MP4文件
      if (isCreateMp4File) {
        const type = +$('input[name=subscribeVideos]:checked').val();
        const subscribeVideos = this.createSubscribeVideos(type);

        const videoFileCfg = {};
        videoFileCfg.aStreamType = +$('input[name=aStreamType]:checked').val() == 0 ? 0 : 1;
        videoFileCfg.svrPathName = `${svrPath}/$UID$_cam$CAMID$_$TIME$.mp4`;
        videoFileCfg.subscribeVideos = subscribeVideos;

        jsonCfg.videoFileCfg = videoFileCfg;
      }
      //如果需要生成MP3文件
      if (isCreateMp3File) {
        const subscribeAudios = this.createSubscribeAudios(+$('input[name=subscribeAudios]:checked').val());

        const audioFileCfg = {};
        audioFileCfg.svrPathName = `${svrPath}/$UID$_$TIME$.mp3`;
        audioFileCfg.subscribeAudios = subscribeAudios;
        jsonCfg.audioFileCfg = audioFileCfg;
      }

      $('#unaflowRecordBtn').text('录制启动中...').prop('disabled', true);
      window.CRVideo_CreateCloudMixer(jsonCfg);
    }
    // 点击创建合流录制
    createInterflowMixer() {
      const jsonCfg = {
        mode: 0, //合流模式为0
      };

      const ossCfg = this.updateThirdPartyCloud();
      if (ossCfg) {
        jsonCfg.storageConfig = ossCfg;
      }

      const { year, month, day, hour, minute, second } = MeetingDemo.getDate(),
        isCreateMp3File = $('#isCreateInterflowMp3File')[0].checked,
        isCreateMp4File = $('#isCreateInterflowMp4File')[0].checked,
        isOpenLiveStream = $('#isOpenLiveStream')[0].checked,
        meetID = MeetingDemo.RoomMgr.meetID;

      if (isCreateMp3File) {
        const aChannelType = +$('input[name=audioTpyeForMp3]:checked').val(); //0单声道，1左右声道

        const path = `/${year}-${month}-${day}/${year}-${month}-${day}_${hour}-${minute}-${second}_web_${meetID}.mp3`;

        const audioFileCfg = {
          svrPathName: path,
          aChannelType: aChannelType,
        };

        //录制左右声道仅录制前两个用户
        if (aChannelType === 1) {
          const aChannelContent = [];
          const members = MeetingDemo.MemberMgr.members;
          if (members.length < 2) {
            MeetingDemo.tipLayer('房间人数少于2人，不能录制左右声道', 2000);
            return;
          }

          members.slice(0, 2).map((m) => aChannelContent.push(m.userID));
          audioFileCfg.aChannelContent = aChannelContent;
        }

        jsonCfg.audioFileCfg = audioFileCfg;
      }

      if (isCreateMp4File || isOpenLiveStream) {
        const pathArr = [];

        if (isCreateMp4File) {
          const path = `/${year}-${month}-${day}/${year}-${month}-${day}_${hour}-${minute}-${second}_web_${meetID}.mp4`;
          pathArr.push(path);
        }

        if (isOpenLiveStream) {
          const path = $('#liveStreamVal').val().trim();
          path && pathArr.push(path);
        }

        const aChannelType = +$('input[name=audioTpyeForMp4]:checked').val(); //0单声道，1左右声道

        const { width, height } = this.interflowVideoCfg;

        const videoFileCfg = {
          svrPathName: pathArr.join(';'),
          aChannelType: aChannelType,
          vWidth: width,
          vHeight: height,
          layoutConfig: this.createLayoutConfig(),
        };

        //录制左右声道仅录制前两个用户
        if (aChannelType === 1) {
          const aChannelContent = [];
          const members = MeetingDemo.MemberMgr.members;
          if (members.length < 2) {
            MeetingDemo.tipLayer('房间人数少于2人，不能录制左右声道', 2000);
            return;
          }

          members.slice(0, 2).map((m) => aChannelContent.push(m.userID));
          videoFileCfg.aChannelContent = aChannelContent;
        }

        //录制左右声道仅录制前两个用户
        if (aChannelType === 1) {
          const aChannelContent = [];
          const members = MeetingDemo.MemberMgr.members;
          if (members.length < 2) {
            MeetingDemo.tipLayer('房间人数少于2人，不能录制左右声道', 2000);
            return;
          }

          members.slice(0, 2).map((m) => aChannelContent.push(m.userID));
          videoFileCfg.aChannelContent = aChannelContent;
        }

        jsonCfg.videoFileCfg = videoFileCfg;
      }

      $('#interflowRecordBtn').text('录制启动中...').prop('disabled', true);
      window.CRVideo_CreateCloudMixer(jsonCfg);
    }
    // 查询录制
    getAllCloudMixerInfo() {
      const allMixerInfo = CRVideo_GetAllCloudMixerInfo();
      this.allMixerInfo = allMixerInfo;
      let myUnaflow = null,
        myInterflow = null;

      allMixerInfo.forEach((item) => {
        if (item.cfg.mode === 1 && item.owner && item.owner == MeetingDemo.Login.userID) {
          myUnaflow = item;
        } else if (item.cfg.mode === 0 && item.owner && item.owner == MeetingDemo.Login.userID) {
          myInterflow = item;
        }
      });

      if (myUnaflow) {
        if (myUnaflow.state === 2) {
          $('#unaflowRecordBtn').text('停止录制').prop('disabled', false);
        }
      } else {
        $('#unaflowRecordBtn').text('开始单流录制').prop('disabled', false);
      }

      if (myInterflow) {
        if (myInterflow.state === 2) {
          $('#interflowRecordBtn').text('停止录制').prop('disabled', false);
        }
      } else {
        $('#interflowRecordBtn').text('开始合流录制').prop('disabled', false);
      }

      this.myUnaflow = myUnaflow;
      this.myInterflow = myInterflow;
    }
    // 获取录制布局
    createLayoutConfig() {
      const { width: W, height: H } = this.interflowVideoCfg;
      const userRatio = W / H;

      const videoContents = [], // 视频文件录制内容
        videoItems = [], // 每个视频，有人可能有多个视频
        AllMembers = MeetingDemo.MemberMgr.members;

      // 如果有屏幕共享，暂时只录屏幕共享（也可以屏幕共享和视频都录，就看怎么布局了，这里为了简单就只录屏幕共享了）
      if (MeetingDemo.Screen.isSharing) {
        videoContents.push({
          type: 5,
          left: 0,
          top: 0,
          width: W,
          height: H,
          keepAspectRatio: 1,
        });
      } else if (MeetingDemo.Media.isPlaying) {
        // 影音共享同理
        videoContents.push({
          type: 3,
          left: 0,
          top: 0,
          width: W,
          height: H,
          keepAspectRatio: 1,
        });
      } else {
        AllMembers.forEach((member) => {
          member.allVideos.forEach((item) => {
            videoItems.push({
              userID: item.userID,
              nickname: member.nickname,
              videoID: item.videoID,
            });
          });
        });

        let x = 1, // 每行图像数
          y = 1, // 每列图像数
          w = W, // 每个图像的宽度
          h = H, // 每个图形的高度
          left = 0, // 画面离视频文件最左侧的距离
          top = 0; // 画面离视频文件最顶部的距离

        // 计算画面数量和大小
        if (videoItems.length === 1) {
          x = y = 1;
          w = W;
          h = H;
        } else if (videoItems.length === 2) {
          x = 2;
          y = 1;
          w = parseInt(W / 2);
          h = parseInt(w / userRatio);
        } else if (videoItems.length <= 4) {
          x = 2;
          y = 2;
          w = parseInt(W / x);
          h = parseInt(w / userRatio);
        } else {
          x = 3;
          y = 3;
          w = parseInt(W / x);
          h = parseInt(H / y);
        }

        //会议内没有人打开摄像头，则添加提示
        if (!videoItems.length) {
          videoContents.push({
            type: 10,
            left: W / 2 - 135,
            top: H / 2 - 15,
            param: {
              text: '暂无成员开启摄像头',
              color: '#e21918',
              'font-size': 30,
            },
          });
        }

        videoItems.forEach((item, i) => {
          // 计算画面位置
          const startTop = (H - h * y) / 2;
          const tmpTop = y == 1 ? 0 : parseInt(i / x);
          top = startTop + tmpTop * h;
          left = (i % x) * w;

          // 添加画面内容 - 摄像头画面
          videoContents.push({
            type: 0,
            left: left,
            top: top,
            width: w,
            height: h,
            param: {
              camid: `${item.userID}.${item.videoID}`,
            },
            keepAspectRatio: 1,
          });

          videoContents.push({
            type: 10,
            left: left + 15,
            top: top + 10,
            param: {
              text: `${item.nickname}-${item.videoID}号摄像头`,
              color: '#ffffff',
              'font-size': 14,
            },
          });

          // 如果没开摄像头，添加文字（摄像头已关闭）
          if (CRVideo_GetVideoStatus(item.userID) == 2) {
            videoContents.push({
              type: 10,
              left: left + w / 2 - 90,
              top: top + h / 2 - 15,
              param: {
                text: '摄像头已关闭',
                'font-size:': 30,
                color: '#e21918',
              },
            });
          }
        });
      }

      // 添加时间戳
      videoContents.push({
        type: 10,
        left: W - 300,
        top: H - 60,
        param: {
          text: '%timestamp%',
          'font-size:': 30,
        },
      });

      return videoContents;
    }
  }
  MeetingDemo.Mixer = new _CloudMixerClass();

  // CRVideo_NotifyNetworkDelay.callback = (delay) => {
  //   console.log(`网络延迟 -- ${delay}ms`);
  // };
  // CRVideo_NotifyPacketsDownloadLostRate.callback = (rate) => {
  //   console.log(`下行丢包率 -- ${Math.floor(rate * 100)}%` );
  // };
  // CRVideo_NotifyPacketsUploadLostRate.callback = (rate) => {
  //   console.log(`上行丢包率 -- ${Math.floor(rate * 100)}%` );
  // };
  // CRVideo_NetStateChanged.callback = (state) => {
  //   console.log(`网络评分 -- ${state}`);
  // }

  // navigator.mediaDevices.addEventListener('devicechange', (e) => {
  //   console.log(e);
  //   navigator.mediaDevices.enumerateDevices().then(devices => {
  //     console.log(devices);
  //     const videoinputs = [],
  //     audioinputs = [],
  //     audiooutputs = [];
  //     devices.forEach(item => {
  //       if(item.kind === 'videoinput') {
  //         videoinputs.push(item);
  //       }
  //       if(item.kind === 'audioinput') {
  //         audioinputs.push(item);
  //       }
  //       if(item.kind === 'audiooutput') {
  //         audiooutputs.push(item);
  //       }
  //     })
  //     console.log('videoinputs: ', JSON.stringify(videoinputs));
  //     console.log('audioinputs: ', JSON.stringify(audioinputs));
  //     console.log('audiooutputs: ', JSON.stringify(audiooutputs));
  //   });
  // });

  // CRVideo_NotifyAudioStream.callback = (side, stream ) => {
  //   CRVideo_StartGetAudioPCM(side, 0, {eachTime:1})
  // }

  // CRVideo_NotifyAudioPCMDat.callback = function (aSide, PCMDat) {
  //   const bytes = new Uint8Array(PCMDat.buffer);
  //   const _base64Str = btoa(String.fromCharCode(...bytes));
  //   console.log(_base64Str);
  // };
});
