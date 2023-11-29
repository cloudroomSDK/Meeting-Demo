package com.example.main;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.cloudroom.cloudroomvideosdk.CRMgrCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoSDK;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.LoginDat;
import com.example.meetingdemo.R;
import com.examples.common.VideoSDKHelper;
import com.examples.tool.UITool;
import com.examples.tool.UITool.ConfirmDialogCallback;

@SuppressLint({ "InflateParams", "NewApi", "HandlerLeak" })
/**
 * 入会界面
 * @author admin
 *
 */
public class MgrActivity extends BaseActivity {

	private static final String TAG = "MgrActivity";

	private EditText mMeetIDTV = null;
	private Button mCreateMeetBtn = null;
	private Button mEnterMeetBtn = null;

	private CRMgrCallback mMgrCallback = new CRMgrCallback() {

		// 登陆失败
		@Override
		public void loginFail(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {
			
			enableOption(false);

			mHandler.removeMessages(MSG_LOGIN);

			// 提示登录失败及原因
			VideoSDKHelper.getInstance().showToast(R.string.login_fail, sdkErr);
			// 如果是状态不对导致失败，恢复登录状态到未登陆
			if (sdkErr == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_LOGINSTATE_ERROR) {
				VideoSDKHelper.getInstance().logout();
				mHandler.sendEmptyMessage(MSG_LOGIN);
			} else {
				mHandler.sendEmptyMessageDelayed(MSG_LOGIN, 10 * 1000);
			}
			mLoging = false;
		}

		// 登陆成功
		@Override
		public void loginSuccess(String usrID, String cookie) {
			
			Log.d(TAG, "onLoginSuccess");
			enableOption(true);
			mHandler.removeMessages(MSG_LOGIN);

			// 提示登录成功
			VideoSDKHelper.getInstance().showToast(R.string.login_success);
			VideoSDKHelper.getInstance().setNickName(mLoginData.nickName);
			mLoging = false;
		}

		@Override
		public void lineOff(CRVIDEOSDK_ERR_DEF sdkErr) {
			enableOption(false);
			// 掉线立即重登
			mHandler.removeMessages(MSG_LOGIN);
			mHandler.sendEmptyMessage(MSG_LOGIN);
			VideoSDKHelper.getInstance().showToast(getString(R.string.lineoff),
					(CRVIDEOSDK_ERR_DEF) sdkErr);
			mLoging = false;
		}

	};

	private static final int MSG_LOGIN = 0;
	private Handler mHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			
			switch (msg.what) {
			case MSG_LOGIN:
				doLogin();
				break;
			default:
				break;
			}
			super.handleMessage(msg);
		}

	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_mgr);

        Activity lastActivity = DemoApp.getInstance().getLastActivity(this);
        if (lastActivity != null) {
            finish();
            return;
        }

		// 设置呼叫处理对象
		CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback);

		initViews();

		// mMeetIDTV.setText("82284178");
		// mMeetIDTV.setText("35665298");
	}

	private void initViews() {
		mMeetIDTV = (EditText) findViewById(R.id.et_meetid);
		mCreateMeetBtn = (Button) findViewById(R.id.btn_createmeeting);
		mEnterMeetBtn = (Button) findViewById(R.id.btn_entermeeting);

		TextView version = (TextView) findViewById(R.id.tv_version);
		version.setText(getString(R.string.sdk_ver)
				+ CloudroomVideoSDK.getInstance().GetCloudroomVideoSDKVer());

		enableOption(VideoSDKHelper.getInstance().isLogin());
	}

	@Override
	protected void onRequestPermissionsFinished() {
		super.onRequestPermissionsFinished();
		if (!VideoSDKHelper.getInstance().isLogin()) {
			mHandler.removeMessages(MSG_LOGIN);
			mHandler.sendEmptyMessage(MSG_LOGIN);
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (SettingActivity.bSettingChanged) {
			mHandler.removeMessages(MSG_LOGIN);
			mHandler.sendEmptyMessage(MSG_LOGIN);
            VideoSDKHelper.getInstance().logout();
            if(SettingActivity.bInitDataChanged) {
                DemoApp.getInstance().uninitCloudroomVideoSDK();
                DemoApp.getInstance().initCloudroomVideoSDK();
            }
        }
        SettingActivity.bSettingChanged = false;
        SettingActivity.bInitDataChanged = false;
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mHandler.removeMessages(MSG_LOGIN);
		CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback);
	}

	public void onViewClick(View v) {
		switch (v.getId()) {
		case R.id.btn_entermeeting:
			enterMeeting();
			break;
		case R.id.btn_createmeeting:
			enterMeetingActivity(0, true);
			break;
		case R.id.btn_server_setting:
			openSetting();
			break;
		default:
			break;
		}
	}

	private void enterMeeting() {
		String meetIDStr = mMeetIDTV.getText().toString();
		int meetID = -1;
		try {
			meetID = Integer.parseInt(meetIDStr);
		} catch (Exception e) {
		}
		if (meetID < 0 || meetIDStr.length() != 8) {
			VideoSDKHelper.getInstance().showToast(R.string.err_meetid_prompt);
			return;
		}
		enterMeetingActivity(meetID, false);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			// 显示退出框
			showExitDialog();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	private void openSetting() {
		Intent intent = new Intent(this, SettingActivity.class);
		startActivity(intent);
	}

	private static int USERID_RANDOM = (int) ((Math.random() * 9 + 1) * 1000);

	// 登陆操作
	private void doLogin() {
		mHandler.removeMessages(MSG_LOGIN);
		if (mLoging || VideoSDKHelper.getInstance().isLogin()) {
			return;
		}
		SharedPreferences sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);
		// 获取配置的服务器地址
		String server = sharedPreferences.getString(SettingActivity.KEY_SERVER,
				SDKConfig.DEFAULT_SERVER);
		// 获取配置的账号密码
		String appID = sharedPreferences.getString(
				SettingActivity.KEY_APPID, SDKConfig.DEFAULT_APPID);
		String appSecret = sharedPreferences.getString(SettingActivity.KEY_APPSECRET,
				SDKConfig.DEFAULT_APPSECRET);

		// 登录私有账号昵称，正式商用建议使用有意义的不重复账号
//		String privAcnt = "Android_" + USERID_RANDOM;
		String privAcnt = "Android_" + Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
		String nickName = privAcnt;

		// 检查服务器地址是否为空
		if (TextUtils.isEmpty(server)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_server);
			return;
		}
		// 检查APPID是否为空
		if (TextUtils.isEmpty(appID)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_appid);
			return;
		}
		// 检查APPSECRET是否为空
		if (TextUtils.isEmpty(appSecret)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_appsecret);
			return;
		}
		// 检查昵称是否为空
		if (TextUtils.isEmpty(nickName)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_nickname);
			return;
		}
		doLogin(server, appID, appSecret, nickName, privAcnt);
	}

	private LoginDat mLoginData = null;
	private boolean mLoging = false;

	// 登陆操作
	private void doLogin(String server, String appID, String appSecret,
			String nickName, String privAcnt) {
		// 设置服务器地址
		CloudroomVideoSDK.getInstance().setServerAddr(server);

		// 登录数据对象
		LoginDat loginDat = new LoginDat();
		// 昵称
		loginDat.nickName = nickName;
		// 第三方账号
		loginDat.privAcnt = privAcnt;
		// APPID，使用开通SDK的APPID
		loginDat.authAcnt = appID;
		// APPSECRET必须做MD5处理
		loginDat.authPswd = appSecret;
		// 执行登录操作
		CloudroomVideoMgr.getInstance().login(loginDat);

		// 登录过程中登录按钮不可用
		enableOption(false);
		mHandler.removeMessages(MSG_LOGIN);
		mLoginData = loginDat;
		mLoging = true;
	}

	/**
	 * 显示退出程序提示
	 */
	private void showExitDialog() {
		UITool.showConfirmDialog(this, getString(R.string.quit)
				+ getString(R.string.app_name), new ConfirmDialogCallback() {

			@Override
			public void onOk() {
				// 退出程序
				DemoApp.getInstance().terminalApp();
			}

			@Override
			public void onCancel() {

			}
		});
	}

	private void enterMeetingActivity(int meetID, boolean createMeeting) {
		Intent intent = new Intent(this, MeetingActivity.class);
		MeetingActivity.mMeetID = meetID;
		MeetingActivity.mBCreateMeeting = createMeeting;
		startActivity(intent);
	}

	private void enableOption(boolean enable) {
		mCreateMeetBtn.setEnabled(enable);
		mEnterMeetBtn.setEnabled(enable);
		mMeetIDTV.setEnabled(enable);
	}
}
