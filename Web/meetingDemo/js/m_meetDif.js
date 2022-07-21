/**
 * 此文件是内部修改meetingDemo为临时会议产品使用，SDK开发者无须关注此文件
 */
console.log('====== 视频会议产品 ======');
$('title').text('视频会议');
$('.form_label').text('请输入会议号');
$('#formDesc').text('如果该会议无密码，则无需输入会议密码');
$('#g_meet_id').attr('placeholder', '请输入会议号');
$('#g_meet_pwd').attr('placeholder', '请输入会议密码');
$('#g_nick_name').attr('placeholder', '请输入您的名字');
$('#g_meet_pwd').show();
$('.login_cont .form_input').css('height', '15rem');
$('.enmeet_btn').css('margin-top', '3rem');
$('.login_order').hide();
$('.crmeet_btn').hide();
$('.verson').hide();
$('.page_meet_header').css('width', '100%');
$('.page_meet_record').hide();
$('.icon-setting').hide();