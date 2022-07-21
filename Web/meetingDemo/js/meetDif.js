/**
 * 此文件是内部修改meetingDemo为临时会议产品使用，SDK开发者无须关注此文件
 */
console.log('====== 视频会议产品 ======');
$('.login_form').css('border-radius', '0.1rem');
$('title').text('视频会议');
$('.form_title').text('请输入房间号');
$('#formDesc').text('如果该房间无密码，则无需输入房间密码');
$('.meet_pwd_form').show();
$('.enmeet_btn').css('margin-top', '0.35rem');
$('.login_order').hide();
$('.create_meet_btn').hide();
$('.loginSet').hide();
$('.form_sdkver').hide();
$('.login_form').css('padding-bottom', '0.5rem');

$('.data-channel').hide();
$('.open-channel-btn').hide();

$('.page_meet_logo').text('视频会议');
$('#page_meet_record').hide();
$('#liveStream').hide();
$('#switchToBoardBtn').hide();
$('#openInviteBtn').hide();
$('#crTestBtn').hide();
$('.page_meet_tool').css('width', '7rem');
$('#closeAllMic').hide();



// 加定时器是为了等layui异步执行完毕
const waitingLayuiTimer = setInterval(() => {
    if (window.MeetingDemo != undefined &&
        window.MeetingDemo.RoomMgr != undefined &&
        window.MeetingDemo.RoomMgr.enterMeetingFun != undefined) {
        clearInterval(waitingLayuiTimer);
        MeetingDemo.RoomMgr.enterMeetingFun = (cookie) => {
            console.log(cookie, this);
            const meetID = MeetingDemo.RoomMgr.meetID;
            const meetPwd = $('#g_meet_pwd').val();
            const userID = MeetingDemo.Login.userID;
            const nickname = MeetingDemo.Login.nickname;
            CRVideo_EnterMeeting(MeetingDemo.RoomMgr.meetID, md5(meetPwd), userID, nickname, cookie);
        }
    }
}, 10);