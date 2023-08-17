package com.examples.common;

import java.util.ArrayList;
import java.util.Map;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.widget.Toast;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CRMgrCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_MEETING_DROPPED_REASON;
import com.example.meetingdemo.R;
import com.examples.tool.CRLog;
import com.examples.tool.Tools;
import com.examples.tool.UITool;
import com.google.gson.Gson;

@SuppressLint("HandlerLeak")
/**
 * 本地管理类
 * @author admin
 *
 */
public class VideoSDKHelper {

	private static final String TAG = "VideoCallSDKMgr";

	private Handler mMainHandler = new Handler();

	private VideoSDKHelper() {
		CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback);
		CloudroomVideoMeeting.getInstance().registerCallback(mMeetingCallback);
	}

	private static VideoSDKHelper mInstance = null;

	public static VideoSDKHelper getInstance() {
		synchronized (TAG) {
			if (mInstance == null) {
				mInstance = new VideoSDKHelper();
			}
		}
		return mInstance;
	}

	private CRMgrCallback mMgrCallback = new CRMgrCallback() {

		// 登陆失败
		@Override
		public void loginFail(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {

			mLoginUserID = null;
		}

		// 登陆成功
		@Override
		public void loginSuccess(String usrID, String cookie) {

			mLoginUserID = usrID;
		}

		@Override
		public void lineOff(CRVIDEOSDK_ERR_DEF sdkErr) {

			mLoginUserID = null;
		}

		@Override
		public void notifyCallHungup(String callID, final String useExtDat) {

			mEnterTime = 0;
		}

		@Override
		public void hangupCallSuccess(String callID, String cookie) {

			mEnterTime = 0;
		}
	};

	private CRMeetingCallback mMeetingCallback = new CRMeetingCallback() {

		@Override
		public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF code) {

			mIMmsgList.clear();
			if (code == CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
				mBInMeeting = true;
				mEnterTime = System.currentTimeMillis();
			} else {
				mBInMeeting = false;
			}
		}

		@Override
		public void meetingDropped(CRVIDEOSDK_MEETING_DROPPED_REASON reason) {
			mBInMeeting = false;
		}

		@Override
		public void meetingStopped() {
			mBInMeeting = false;
		}

		@Override
		public void notifyMeetingCustomMsg(String fromUserID, String text) {
			Gson gson = new Gson();
			Map<String, String> map = gson.fromJson(text, Map.class);
			if (map != null && map.containsKey("CmdType")) {
				if (!"IM".equals(map.get("CmdType"))) {
					return;
				}
			} else {
				return;
			}
			String imMsgText = map.get("IMMsg");
			CRLog.debug(TAG, "notifyIMmsg fromUserID:" + fromUserID + " text:"
					+ text);
			IMmsg imMsg = new IMmsg();
			imMsg.fromUserID = fromUserID;
			imMsg.text = imMsgText;
			imMsg.sendTime = (long) System.currentTimeMillis();
			mIMmsgList.add(imMsg);
		}

		@Override
		public void sendMeetingCustomMsgRslt(CRVIDEOSDK_ERR_DEF sdkErr,
				String cookie) {
			CRLog.debug(TAG, "sendIMmsg(" + cookie + ") success");
		}

	};

	public void logout() {
		mLoginUserID = null;
		mNickName = null;
		CloudroomVideoMgr.getInstance().logout();
	}

	private boolean mBInMeeting = false;
	private String mLoginUserID = null;
	private String mNickName = null;

	public String getLoginUserID() {
		return mLoginUserID;
	}

	public boolean isLogin() {
		return mLoginUserID != null;
	}

	public String getNickName() {
		return mNickName;
	}

	public void setNickName(String nickName) {
		this.mNickName = nickName;
	}

	public boolean isInMeeting() {
		return mBInMeeting;
	}

	private long mEnterTime = 0;

	private ArrayList<IMmsg> mIMmsgList = new ArrayList<IMmsg>();

	public long getEnterTime() {
		return mEnterTime;
	}

	public ArrayList<IMmsg> getIMmsgList() {
		return mIMmsgList;
	}

	public void enterMeeting(int meetId) {
		CloudroomVideoMeeting.getInstance().enterMeeting(meetId);
	}

	public String getErrStr(CRVIDEOSDK_ERR_DEF errCode) {
		String str = Tools.LoadString(mContext, errCode.toString());
		if(TextUtils.isEmpty(str)) {
			str = mContext.getString(R.string.CRVIDEOSDK_UNKNOWERR);
		}
		return str;
	}

	private Context mContext = null;

	public void setContext(Context context) {
		this.mContext = context;
	}

	private Toast mToast = null;

	/**
	 * 显示Toast提示
	 * 
	 * @param txt
	 *            Toast文字
	 */
	public void showToast(final String txt) {
		if (TextUtils.isEmpty(txt)) {
			return;
		}
		mMainHandler.post(new Runnable() {

			@Override
			public void run() {
				try {
					if (mToast != null) {
						mToast.cancel();
					}
					mToast = Toast.makeText(mContext, txt, Toast.LENGTH_LONG);
					mToast.show();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * 显示Toast提示
	 * 
	 * @param id
	 */
	public void showToast(int id) {
		showToast(mContext.getString(id));
	}

	/**
	 * 显示Toast提示
	 * 
	 * @param txt
	 * @param err
	 */
	public void showToast(String txt, CRVIDEOSDK_ERR_DEF err) {
		String text = String.format("%s ( %s )", txt, VideoSDKHelper
				.getInstance().getErrStr(err));
		showToast(text);
	}

	/**
	 * 显示Toast提示
	 * 
	 * @param id
	 * @param err
	 */
	public void showToast(final int id, final CRVIDEOSDK_ERR_DEF err) {
		showToast(mContext.getString(id), err);
	}
}
