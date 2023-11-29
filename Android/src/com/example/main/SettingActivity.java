package com.example.main;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.Editable;
import android.text.Selection;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.example.meetingdemo.R;
import com.examples.common.VideoSDKHelper;
import com.examples.tool.MD5Util;
import com.examples.tool.UITool;
import com.examples.tool.UITool.SelectListener;

import java.util.ArrayList;

@SuppressLint("HandlerLeak")
/**
 * 配置界面
 * @author admin
 *
 */
public class SettingActivity extends BaseActivity {

	@SuppressWarnings("unused")
	private static final String TAG = "SettingActivity";

	public static boolean bSettingChanged = false;
	public static boolean bInitDataChanged = false;

	private EditText mServerEditText = null;
	private EditText mAppIDEditText = null;
	private EditText mAppSecretEditText = null;
	private TextView mDatEncTV = null;

	public static final String KEY_SERVER = "server";
	public static final String KEY_APPID = "account";
	public static final String KEY_APPSECRET = "password";
	public static final String KEY_DATENC_TYPE = "datEncType";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_setting);

		mServerEditText = (EditText) findViewById(R.id.et_server);

		mAppIDEditText = (EditText) findViewById(R.id.et_appid);
		mAppSecretEditText = (EditText) findViewById(R.id.et_appsecret);

		mDatEncTV = findViewById(R.id.tv_datenc_type);

		initData();
	}

	private void initData() {
		SharedPreferences sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);

		String server = sharedPreferences.getString(KEY_SERVER, SDKConfig.DEFAULT_SERVER);
		String appID = sharedPreferences.getString(KEY_APPID,
				SDKConfig.DEFAULT_APPID);
		String appSecret = sharedPreferences.getString(KEY_APPSECRET, SDKConfig.DEFAULT_APPSECRET);

		mServerEditText.setText(server);
		mAppIDEditText.setText(appID);
		mAppSecretEditText.setText(appSecret);

		// 光标放到文字最后
		Editable text = mServerEditText.getText();
		Selection.setSelection(text, text.length());

		try {
			ArrayList<String> datEncTypeStrs = UITool.getStringArray(this, R.array.datenc_types);
			String datEncType = sharedPreferences.getString(KEY_DATENC_TYPE,
					SDKConfig.DEFAULT_DATENC_TYPE);
			mDatEncTV.setText(datEncTypeStrs.get(Integer.parseInt(datEncType)));
		} catch (Exception e) {
		}
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
			saveAndFinish();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	// 控件点击处理方法
	public void onViewClick(View v) {
		switch (v.getId()) {
		case R.id.titlebar_iv_left:
			finish();
			break;
		case R.id.btn_restore:
			mServerEditText.setText(SDKConfig.DEFAULT_SERVER);
			mAppIDEditText.setText(SDKConfig.DEFAULT_APPID);
			mAppSecretEditText.setText(SDKConfig.DEFAULT_APPSECRET);
			ArrayList<String> datEncTypeStrs = UITool.getStringArray(this, R.array.datenc_types);
			mDatEncTV.setText(datEncTypeStrs.get(Integer.parseInt(SDKConfig.DEFAULT_DATENC_TYPE)));
			saveAndFinish();
			break;
		case R.id.tv_datenc_type:
			showDatEncTypeDialog();
			break;
		case R.id.titlebar_tv_right:
			saveAndFinish();
			break;
		default:
			break;
		}
	}

	private void showDatEncTypeDialog() {
		ArrayList<String> datEncTypeStrs = UITool.getStringArray(this,
				R.array.datenc_types);

		String datEncTypeStr = mDatEncTV.getText().toString();
		UITool.showSingleChoiceDialog(this,
				getString(R.string.datenc_type), datEncTypeStrs, datEncTypeStr,
				new SelectListener() {

					@Override
					public void onSelect(int index, String item) {
						mDatEncTV.setText(item);
					}
				});
	}

	private void saveAndFinish() {
		String server = mServerEditText.getText().toString();
		String appID = mAppIDEditText.getText().toString();
		String appSecret = mAppSecretEditText.getText().toString();
		if (TextUtils.isEmpty(server)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_server);
			return;
		}
		if (TextUtils.isEmpty(appID)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_appid);
			return;
		}
		if (TextUtils.isEmpty(appSecret)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_appsecret);
			return;
		}

		String datEncTypeStr = mDatEncTV.getText().toString();
		ArrayList<String> datEncTypeStrs = UITool.getStringArray(this,
				R.array.datenc_types);
		String datEncType = "" + datEncTypeStrs.indexOf(datEncTypeStr);

		SharedPreferences sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);
		String oldAppSecret = sharedPreferences
				.getString(KEY_APPSECRET, SDKConfig.DEFAULT_APPSECRET);
		String oldAppID = sharedPreferences.getString(KEY_APPID,
				SDKConfig.DEFAULT_APPID);
		String oldServer = sharedPreferences.getString(KEY_SERVER,
				SDKConfig.DEFAULT_SERVER);
		String oldDatEncType = sharedPreferences.getString(KEY_DATENC_TYPE,
				SDKConfig.DEFAULT_DATENC_TYPE);

		Editor editor = sharedPreferences.edit();

		if(!oldDatEncType.equals(datEncType)) {
			editor.putString(KEY_DATENC_TYPE, datEncType);
			Log.i("", "datEncType:" + datEncType);
			bSettingChanged = true;
			bInitDataChanged = true;
		}

		if(!oldAppSecret.equals(appSecret)) {
			// 判断是否恢复默认
			if (!SDKConfig.DEFAULT_APPSECRET.equals(appSecret)) {
				appSecret = MD5Util.MD5(appSecret);
			}
			if (TextUtils.isEmpty(appSecret)) {
				editor.remove(KEY_APPSECRET);
			} else {
				editor.putString(KEY_APPSECRET, appSecret);
			}
			bSettingChanged = true;
		}

		if(!oldServer.equals(server)) {
			if (TextUtils.isEmpty(server)) {
				editor.remove(KEY_SERVER);
			} else {
				editor.putString(KEY_SERVER, server);
			}
			bSettingChanged = true;
		}
		if(!oldAppID.equals(appID)) {
			if (TextUtils.isEmpty(appID)) {
				editor.remove(KEY_APPID);
			} else {
				editor.putString(KEY_APPID, appID);
			}
			bSettingChanged = true;
		}

		editor.commit();
		finish();
	}

}
