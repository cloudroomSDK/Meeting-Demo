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
	private EditText mAccountEditText = null;
	private EditText mPswdEditText = null;
	private TextView mDatEncTV = null;

	public static final String KEY_SERVER = "server";
	public static final String KEY_ACCOUNT = "account";
	public static final String KEY_PSWD = "password";
	public static final String KEY_DATENC_TYPE = "datEncType";

	public static final String DEFAULT_SERVER = "sdk.cloudroom.com";
	public static final String DEFAULT_ACCOUNT = "demo@cloudroom.com";
	public static final String DEFAULT_PSWD = MD5Util.MD5("123456");
	public static final String DEFAULT_DATENC_TYPE = "1";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_setting);

		mServerEditText = (EditText) findViewById(R.id.et_server);

		mAccountEditText = (EditText) findViewById(R.id.et_account);
		mPswdEditText = (EditText) findViewById(R.id.et_pswd);

		mDatEncTV = findViewById(R.id.tv_datenc_type);

		initData();
	}

	private void initData() {
		SharedPreferences sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);

		String server = sharedPreferences.getString(KEY_SERVER, DEFAULT_SERVER);
		String account = sharedPreferences.getString(KEY_ACCOUNT,
				DEFAULT_ACCOUNT);
		String pswd = sharedPreferences.getString(KEY_PSWD, DEFAULT_PSWD);

		mServerEditText.setText(server);
		mAccountEditText.setText(account);
		mPswdEditText.setText(pswd);

		// 光标放到文字最后
		Editable text = mServerEditText.getText();
		Selection.setSelection(text, text.length());

		try {
			ArrayList<String> datEncTypeStrs = UITool.getStringArray(this, R.array.datenc_types);
			String datEncType = sharedPreferences.getString(KEY_DATENC_TYPE,
					DEFAULT_DATENC_TYPE);
			mDatEncTV.setText(datEncTypeStrs.get(Integer.parseInt(datEncType)));
		} catch (Exception e) {
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
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
			mServerEditText.setText(DEFAULT_SERVER);
			mAccountEditText.setText(DEFAULT_ACCOUNT);
			mPswdEditText.setText(DEFAULT_PSWD);
			ArrayList<String> datEncTypeStrs = UITool.getStringArray(this, R.array.datenc_types);
			mDatEncTV.setText(datEncTypeStrs.get(Integer.parseInt(DEFAULT_DATENC_TYPE)));
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
		String account = mAccountEditText.getText().toString();
		String pswd = mPswdEditText.getText().toString();
		if (TextUtils.isEmpty(server)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_server);
			return;
		}
		if (TextUtils.isEmpty(account)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_account);
			return;
		}
		if (TextUtils.isEmpty(pswd)) {
			VideoSDKHelper.getInstance().showToast(R.string.null_pswd);
			return;
		}

		String datEncTypeStr = mDatEncTV.getText().toString();
		ArrayList<String> datEncTypeStrs = UITool.getStringArray(this,
				R.array.datenc_types);
		String datEncType = "" + datEncTypeStrs.indexOf(datEncTypeStr);

		SharedPreferences sharedPreferences = PreferenceManager
				.getDefaultSharedPreferences(this);
		String oldPswd = sharedPreferences
				.getString(KEY_PSWD, DEFAULT_PSWD);
		String oldAccount = sharedPreferences.getString(KEY_ACCOUNT,
				DEFAULT_ACCOUNT);
		String oldServer = sharedPreferences.getString(KEY_SERVER,
				DEFAULT_SERVER);
		String oldDatEncType = sharedPreferences.getString(KEY_DATENC_TYPE,
				DEFAULT_DATENC_TYPE);

		Editor editor = sharedPreferences.edit();

		if(!oldDatEncType.equals(datEncType)) {
			editor.putString(KEY_DATENC_TYPE, datEncType);
			Log.i("", "datEncType:" + datEncType);
			bSettingChanged = true;
			bInitDataChanged = true;
		}

		if(!oldPswd.equals(pswd)) {
			// 判断密码是否恢复默认
			if (!DEFAULT_PSWD.equals(pswd)) {
				pswd = MD5Util.MD5(pswd);
			}
			if (TextUtils.isEmpty(pswd)) {
				editor.remove(KEY_PSWD);
			} else {
				editor.putString(KEY_PSWD, pswd);
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
		if(!oldAccount.equals(account)) {
			if (TextUtils.isEmpty(account)) {
				editor.remove(KEY_ACCOUNT);
			} else {
				editor.putString(KEY_ACCOUNT, account);
			}
			bSettingChanged = true;
		}

		editor.commit();
		finish();
	}

}
