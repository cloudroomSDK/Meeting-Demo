package com.example.main;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Message;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CRMgrCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMgr;
import com.cloudroom.cloudroomvideosdk.MediaUIView;
import com.cloudroom.cloudroomvideosdk.ScreenShareUIView;
import com.cloudroom.cloudroomvideosdk.model.ASTATUS;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_MEETING_DROPPED_REASON;
import com.cloudroom.cloudroomvideosdk.model.MEDIA_STOP_REASON;
import com.cloudroom.cloudroomvideosdk.model.MeetInfo;
import com.cloudroom.cloudroomvideosdk.model.Size;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoInfo;
import com.cloudroom.cloudroomvideosdk.model.VSTATUS;
import com.cloudroom.cloudroomvideosdk.model.VideoCfg;
import com.example.meetingdemo.R;
import com.examples.common.IMmsg;
import com.examples.common.VideoSDKHelper;
import com.examples.common.WheelView;
import com.examples.tool.UITool;
import com.examples.tool.UITool.ConfirmDialogCallback;
import com.google.gson.Gson;

@SuppressLint({ "NewApi", "HandlerLeak", "ClickableViewAccessibility",
		"DefaultLocale" })
/**
 * 会议界面
 * @author admin
 *
 */
public class MeetingActivity extends BaseActivity implements OnTouchListener,
		Callback {

	private static final String TAG = "MeetingActivity";

	private static final int PAGER_VIDEOWALL_PAGE = 0;
	private static final int PAGER_SCREENSHARE_PARE = 1;
	private static final int PAGER_MEDIASHARE_PARE = 2;
	private ViewPager mMainPager = null;
	private ArrayList<View> mMainPagerViewList = new ArrayList<View>();

	public static int mMeetID = 0;
	public static boolean mBCreateMeeting = false;

	private ImageView mCameraIV = null;
	private ImageView mMicIV = null;
	private TextView mCameraTV = null;
	private TextView mMicTV = null;
	private ImageView mNetStateIV = null;

	private View mOPtionTopBar = null;

	private VideoWallView mVideoWallView = null;
	private boolean mBScreenShareStarted = false;
	private boolean mBMediaStarted = false;

	private static final int[] NET_STATE_RESID = { R.drawable.netstate_1,
			R.drawable.netstate_2, R.drawable.netstate_3,
			R.drawable.netstate_4, R.drawable.netstate_5 };

	private static final int MSG_HIDE_OPTION = 1002;

	private CRMgrCallback mMgrCallback = new CRMgrCallback() {

		@Override
		public void lineOff(CRVIDEOSDK_ERR_DEF sdkErr) {
			VideoSDKHelper.getInstance().showToast(R.string.meet_dropped);
			exitMeeting();
		}

		@Override
		public void createMeetingFail(CRVIDEOSDK_ERR_DEF sdkErr, String cookie) {
			// 创建会议失败，提示并退出界面
			VideoSDKHelper.getInstance().showToast(R.string.create_meet_fail,
					sdkErr);
			UITool.hideProcessDialog(MeetingActivity.this);
			finish();
		}

		@Override
		public void createMeetingSuccess(MeetInfo meetInfo, String cookie) {
			// 创建会议成功直接进入会议
			enterMeeting(meetInfo.ID);
		}

	};

	private CRMeetingCallback mMeetingCallback = new CRMeetingCallback() {

		@Override
		public void notifyMainVideoChanged() {
			Log.d(TAG, "notifyMainVideoChanged");
		}

		/**
		 * 进入会议结果
		 * 
		 * @param code
		 *            结果
		 */
		@Override
		public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF code) {
			UITool.hideProcessDialog(MeetingActivity.this);
			if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
				VideoSDKHelper.getInstance().showToast(R.string.enter_fail,
						code);
				exitMeeting();
				return;
			}

			enterMeetingSuccess();

			watchHeadset();
			VideoSDKHelper.getInstance().showToast(R.string.enter_success);
			updateCameraBtn();
			updateMicBtn();

			showOption();

			// 如果默认使用的时听筒， 开启外放
			if (mSpeakType <= 1) {
				CloudroomVideoMeeting.getInstance().setSpeakerOut(true);
			}
		}

		@Override
		public void notifyNickNameChanged(String userID, String oldname,
				String newname) {
			Log.d(TAG, "notifyNickNameChanged userID:" + userID + " oldname:"
					+ oldname + " newname:" + newname);
		}

		@Override
		public void setNickNameRsp(CRVIDEOSDK_ERR_DEF sdkErr, String userid,
				String newname) {
			Log.d(TAG, "setNickNameRsp:" + sdkErr + " userid:" + userid
					+ " newname:" + newname);
		}

		@Override
		public void audioStatusChanged(String userID, ASTATUS oldStatus,
				ASTATUS newStatus) {
			updateMicBtn();
		}

		@Override
		public void meetingDropped(CRVIDEOSDK_MEETING_DROPPED_REASON reason) {
			VideoSDKHelper.getInstance().showToast(R.string.meet_dropped);
			exitMeeting();
		}

		@Override
		public void meetingStopped() {
			VideoSDKHelper.getInstance().showToast(R.string.meet_stopped);
			exitMeeting();
		}

		@Override
		public void micEnergyUpdate(String userID, int oldLevel, int newLevel) {
			String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
			if (myUserID.equals(userID)) {
				// mMicPB.setProgress(newLevel % mMicPB.getMax());
			}
		}

		@Override
		public void videoDevChanged(String userID) {
		}

		@Override
		public void videoStatusChanged(String userID, VSTATUS oldStatus,
				VSTATUS newStatus) {
			updateCameraBtn();
		}

		@Override
		public void netStateChanged(int level) {
			int resId = R.drawable.netstate_1;
			int index = (level + 1) / 2;
			if (index < 0) {
				resId = R.drawable.netstate_1;
			} else if (index >= NET_STATE_RESID.length) {
				resId = R.drawable.netstate_5;
			} else {
				resId = NET_STATE_RESID[index];
			}
			mNetStateIV.setImageResource(resId);
		}

		@SuppressWarnings({ "unchecked", "unchecked" })
		@Override
		public void notifyMeetingCustomMsg(String fromUserID, String text) {
			Gson gson = new Gson();
			Map<String, String> map = gson.fromJson(text, Map.class);
			if (map.containsKey("CmdType")) {
				if (!"IM".equals(map.get("CmdType"))) {
					return;
				}
			} else {
				return;
			}
			// 收到聊天消息刷新界面
			mIMAdapter.notifyDataSetChanged();
			mIMListView.setSelection(mIMAdapter.getCount() - 1);
		}

		@Override
		public void notifyScreenShareStarted() {
			mBScreenShareStarted = true;
			VideoSDKHelper.getInstance()
					.showToast(R.string.screenshare_started);
			updateMainPager();
		}

		@Override
		public void notifyScreenShareStopped() {
			mBScreenShareStarted = false;
			VideoSDKHelper.getInstance()
					.showToast(R.string.screenshare_stopped);
			updateMainPager();
		}

		@Override
		public void notifyMediaStart(String userid) {
			mBMediaStarted = true;
			updateMainPager();
		}

		@Override
		public void notifyMediaStop(String userid, MEDIA_STOP_REASON reason) {
			mBMediaStarted = false;
			updateMainPager();
		}

		int mSpeakType = 0;

		public void notifySpeakerChanged(int speakType) {
			Log.d(TAG, "notifySpeakerChanged speakType:" + speakType);
			mSpeakType = speakType;
		};
	};

	@Override
	public boolean handleMessage(Message msg) {
		switch (msg.what) {
		case MSG_HIDE_OPTION:
			hideOption();
			break;
		default:
			break;
		}
		return false;
	}

	public Handler mMainHandler = new Handler(this);

	private PagerAdapter mMainPagerAdapter = new PagerAdapter() {

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}

		@Override
		public int getCount() {
			return mMainPagerViewList.size();
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView(mMainPagerViewList.get(position));
		}

		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			container.addView(mMainPagerViewList.get(position),
					new LayoutParams(LayoutParams.MATCH_PARENT,
							LayoutParams.MATCH_PARENT));
			return mMainPagerViewList.get(position);
		}
	};

	private void exitMeeting() {
		// 离开会议
		CloudroomVideoMeeting.getInstance().exitMeeting();
		finish();
	}

	private void showExitDialog() {
		UITool.showConfirmDialog(this, getString(R.string.exit_meeting),
				new ConfirmDialogCallback() {

					@Override
					public void onOk() {
						exitMeeting();
					}

					@Override
					public void onCancel() {
					}
				});
	}

	@SuppressLint("ClickableViewAccessibility")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		setContentView(R.layout.activity_meeting);

		if (mMeetID <= 0 && !mBCreateMeeting) {
			finish();
			return;
		}

		initViews();

		CloudroomVideoMeeting.getInstance().registerCallback(mMeetingCallback);
		CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback);

		updateCameraBtn();
		updateMicBtn();

		if (mBCreateMeeting) {
			createMeeting();
		} else {
			enterMeeting(mMeetID);
		}

		mMainHandler.post(new Runnable() {

			@Override
			public void run() {
				UITool.showProcessDialog(MeetingActivity.this,
						getString(R.string.entering));
			}
		});

		setVolumeControlStream(AudioManager.STREAM_VOICE_CALL);
	}

	private void initViews() {
		mOPtionTopBar = findViewById(R.id.view_option_topbar);

		mMicIV = (ImageView) findViewById(R.id.iv_mic);
		mCameraIV = (ImageView) findViewById(R.id.iv_camera);
		mMicTV = (TextView) findViewById(R.id.tv_mic);
		mCameraTV = (TextView) findViewById(R.id.tv_camera);

		mNetStateIV = (ImageView) findViewById(R.id.iv_network_state);

		// 初始化控件
		mIMInputBar = findViewById(R.id.view_im_input_bar);
		mIMInputET = (EditText) findViewById(R.id.et_im_input);
		mIMListView = (ListView) findViewById(R.id.list_im_message);

		ArrayList<IMmsg> immsgs = VideoSDKHelper.getInstance().getIMmsgList();
		immsgs.clear();
		mIMAdapter = new IMAdapter(this, R.layout.layout_immsg_item, immsgs);
		mIMListView.setAdapter(mIMAdapter);

		mMainPager = (ViewPager) findViewById(R.id.vp_main);

		mVideoWallView = new VideoWallView(this);
		mMainPagerViewList.add(mVideoWallView);
		mMainPagerViewList.add(new ScreenShareUIView(this));
		mMainPagerViewList.add(new MediaUIView(this));

		mMainPager.setAdapter(mMainPagerAdapter);

		View view = getWindow().getDecorView();
		view.setOnTouchListener(this);

		// 显示视频需要启用hardwareAccelerated，某些设备会导致控件花屏，需要把不需要使用硬件加速的控件关闭硬件加速功能
		findViewById(R.id.view_option_bottombar).setLayerType(
				View.LAYER_TYPE_SOFTWARE, null);
		mOPtionTopBar.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		mIMInputBar.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
		mIMListView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
	}

	// 创建会议
	private void createMeeting() {
		// 创建会议
		CloudroomVideoMgr.getInstance().createMeeting("Android Meeting", false,
				TAG);
	}

	// 进入会议
	private void enterMeeting(int meetID) {
		// 进入会议
		VideoSDKHelper.getInstance().enterMeeting(meetID);

		TextView titleTV = (TextView) findViewById(R.id.tv_title);
		titleTV.setText(getString(R.string.meet_prompt, meetID));
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		unwatchHeadset();
		CloudroomVideoMeeting.getInstance().exitMeeting();
		CloudroomVideoMeeting.getInstance()
				.unregisterCallback(mMeetingCallback);
		CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback);
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
			showExitDialog();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	// 成功进入会议
	private void enterMeetingSuccess() {
		// 设置默认值
		VideoCfg videoCfg = new VideoCfg();
		videoCfg.fps = 15;
		videoCfg.maxbps = -1;
		videoCfg.minQuality = 22;
		videoCfg.maxQuality = 25;
		videoCfg.size = new Size(360, 360);
		CloudroomVideoMeeting.getInstance().setVideoCfg(videoCfg);

		String myUserID = CloudroomVideoMeeting.getInstance().getMyUserID();
		// 默认使用前置摄像头
		ArrayList<UsrVideoInfo> myVideos = CloudroomVideoMeeting.getInstance()
				.getAllVideoInfo(myUserID);
		for (UsrVideoInfo vInfo : myVideos) {
			if (vInfo.videoName.contains("FRONT")) {
				CloudroomVideoMeeting.getInstance().setDefaultVideo(myUserID,
						vInfo.videoID);
				break;
			}
		}

		// // 多档视频实现, 出多档质量的视频流，将带来很大的cpu开销
		// short defaultVideoID = CloudroomVideoMeeting.getInstance()
		// .getDefaultVideo(myUserID);
		// VideoAttributes attr = new VideoAttributes();
		// // 配置第二档视频
		// VideoCfg cfg = new VideoCfg();
		// cfg.fps = 15;
		// cfg.maxbps = -1;
		// cfg.minQuality = 22;
		// cfg.maxQuality = 25;
		// cfg.size = new Size(80, 80);
		// attr.quality2Cfg = cfg;
		// CloudroomVideoMeeting.getInstance().setLocVideoAttributes(
		// defaultVideoID, attr);

		// 打开摄像头
		CloudroomVideoMeeting.getInstance().openVideo(myUserID);
		// //设置摄像头焦距，需要摄像头打开之后才能设置，重新打开摄像头以前的设置失效
		// short videoID = CloudroomVideoMeeting.getInstance().getDefaultVideo(
		// myUserID);
		// String params = CloudroomVideoMeeting.getInstance()
		// .getLocalVideoParams(videoID);
		// Log.d(TAG, "getLocalVideoParams:" + params);
		// CloudroomVideoMeeting.getInstance().setLocalVideoParam(videoID,
		// "zoom",
		// "" + 270);

		// 打开麦克风
		CloudroomVideoMeeting.getInstance().openMic(myUserID);
	}

	private void updateCameraBtn() {
		String userId = CloudroomVideoMeeting.getInstance().getMyUserID();
		VSTATUS status = CloudroomVideoMeeting.getInstance().getVideoStatus(
				userId);
		if (status == VSTATUS.VOPEN || status == VSTATUS.VOPENING) {
			mCameraIV.setImageResource(R.drawable.camera_opened);
			mCameraTV.setText(R.string.close_camera);
		} else {
			mCameraIV.setImageResource(R.drawable.camera_closed);
			mCameraTV.setText(R.string.open_camera);
		}
	}

	private void updateMicBtn() {
		String userId = CloudroomVideoMeeting.getInstance().getMyUserID();
		ASTATUS status = CloudroomVideoMeeting.getInstance().getAudioStatus(
				userId);
		if (status == ASTATUS.AOPEN || status == ASTATUS.AOPENING) {
			mMicIV.setImageResource(R.drawable.mic_opened);
			mMicTV.setText(R.string.close_mic);
		} else {
			mMicIV.setImageResource(R.drawable.mic_closed);
			mMicTV.setText(R.string.open_mic);
		}
	}

	private void updateMainPager() {
		if (mBScreenShareStarted) {
			mMainPager.setCurrentItem(PAGER_SCREENSHARE_PARE, false);
			return;
		}
		if (mBMediaStarted) {
			mMainPager.setCurrentItem(PAGER_MEDIASHARE_PARE, false);
			return;
		}
		mMainPager.setCurrentItem(PAGER_VIDEOWALL_PAGE, false);
	}

	public void onViewClick(View v) {
		String userId = CloudroomVideoMeeting.getInstance().getMyUserID();
		switch (v.getId()) {
		case R.id.btn_exit_meeting:
			showExitDialog();
			break;
		case R.id.btn_mic: {
			ASTATUS status = CloudroomVideoMeeting.getInstance()
					.getAudioStatus(userId);
			if (status == ASTATUS.AOPEN || status == ASTATUS.AOPENING) {
				CloudroomVideoMeeting.getInstance().closeMic(userId);
			} else {
				CloudroomVideoMeeting.getInstance().openMic(userId);
			}
			break;
		}
		case R.id.btn_camera: {
			VSTATUS status = CloudroomVideoMeeting.getInstance()
					.getVideoStatus(userId);
			if (status == VSTATUS.VOPEN || status == VSTATUS.VOPENING) {
				CloudroomVideoMeeting.getInstance().closeVideo(userId);
			} else {
				CloudroomVideoMeeting.getInstance().openVideo(userId);
			}
			break;
		}
		case R.id.btn_switchcamera:
			switchCamera();
			break;
		case R.id.btn_resolution:
			showVideoResolutionDialog();
			break;
		case R.id.btn_fps:
			showVideoFpsDialog();
			break;
		case R.id.btn_im:
			showImMsg(true);
			break;
		case R.id.btn_im_down:
			showImMsg(false);
			break;
		case R.id.btn_im_send:
			sendMsg();
			break;
		default:
			break;
		}
	}

	private void switchCamera() {
		String userId = CloudroomVideoMeeting.getInstance().getMyUserID();
		short curDev = CloudroomVideoMeeting.getInstance().getDefaultVideo(
				userId);
		ArrayList<UsrVideoInfo> devs = CloudroomVideoMeeting.getInstance()
				.getAllVideoInfo(userId);

		if (devs.size() > 1) {
			UsrVideoInfo info = devs.get(0);
			boolean find = false;
			for (UsrVideoInfo dev : devs) {
				if (find) {
					info = dev;
					break;
				} else if (dev.videoID == curDev) {
					find = true;
				}
			}
			CloudroomVideoMeeting.getInstance().setDefaultVideo(info.userId,
					info.videoID);
		}
	}

	private HeadsetReceiver mHeadsetReceiver = null;

	private void watchHeadset() {
		if (mHeadsetReceiver != null) {
			return;
		}
		mHeadsetReceiver = new HeadsetReceiver();
		IntentFilter filter = new IntentFilter();
		filter.addAction(Intent.ACTION_HEADSET_PLUG);
		registerReceiver(mHeadsetReceiver, filter);
	}

	private void unwatchHeadset() {
		if (mHeadsetReceiver == null) {
			return;
		}
		unregisterReceiver(mHeadsetReceiver);
		mHeadsetReceiver = null;
	}

	private class HeadsetReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			Log.d(TAG, "HeadsetReceiver : " + action);
			if (intent.hasExtra("state")) {
				int state = intent.getIntExtra("state", 0);
				Log.d(TAG, "HeadsetReceiver state:" + state);
				CloudroomVideoMeeting.getInstance()
						.setSpeakerOut(!(state == 1));
				boolean speakerOut = CloudroomVideoMeeting.getInstance()
						.getSpeakerOut();
				Log.d(TAG, "setSpeakerOut:" + speakerOut);
			}
		}
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		int action = event.getAction();
		switch (action) {
		case MotionEvent.ACTION_DOWN:
		case MotionEvent.ACTION_UP:
			showOption();
			break;
		}
		return true;
	}

	private void showOption() {
		Log.d(TAG, "showOption");
		mMainHandler.removeMessages(MSG_HIDE_OPTION);
		mOPtionTopBar.setVisibility(View.VISIBLE);
		mMainHandler.sendEmptyMessageDelayed(MSG_HIDE_OPTION, 3 * 1000);
	}

	private void hideOption() {
		Log.d(TAG, "hideOption");
		mMainHandler.removeMessages(MSG_HIDE_OPTION);
		mOPtionTopBar.setVisibility(View.GONE);
	}

	private interface SelectListener {
		void onSelect(int index, String item);
	}

	@SuppressLint("InflateParams")
	private void showSingleChoiceDialog(String title, ArrayList<String> items,
			String curValue, final SelectListener selectListener) {
		View view = getLayoutInflater().inflate(R.layout.layout_select_dailog,
				null);
		TextView cancelBtn = (TextView) view.findViewById(R.id.cancel);
		TextView okBtn = (TextView) view.findViewById(R.id.ok);
		TextView titleView = (TextView) view.findViewById(R.id.title);
		final WheelView wheelView = (WheelView) view
				.findViewById(R.id.view_wheel);

		titleView.setText(title);
		wheelView.setItems(items);

		int curIndex = items.indexOf(curValue);
		if (curIndex <= 0) {
			curIndex = 0;
		}
		wheelView.setSeletion(curIndex);

		final ButtomDialog dialog = new ButtomDialog(this, view);

		cancelBtn.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		okBtn.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				selectListener.onSelect(wheelView.getSeletedIndex(),
						wheelView.getSeletedItem());
				dialog.dismiss();
			}
		});

		dialog.show();
	}

	private ArrayList<String> getStringArray(int arrayID) {
		String[] array = getResources().getStringArray(arrayID);
		ArrayList<String> list = new ArrayList<String>();
		for (String str : array) {
			list.add(str);
		}
		return list;
	}

	private void showVideoResolutionDialog() {
		ArrayList<String> videosizes = getStringArray(R.array.videosizes);
		Size size = CloudroomVideoMeeting.getInstance().getVideoCfg().size;
		String sizeStr = String.format("%d*%d", size.width, size.height);

		showSingleChoiceDialog(getString(R.string.video_resolution),
				videosizes, sizeStr, new SelectListener() {

					@Override
					public void onSelect(int index, String item) {
						String[] sizeStrs = item.split("\\*");
						VideoCfg cfg = CloudroomVideoMeeting.getInstance()
								.getVideoCfg();
						cfg.size = new Size(Integer.parseInt(sizeStrs[0]),
								Integer.parseInt(sizeStrs[1]));
						cfg.maxbps = -1;
						CloudroomVideoMeeting.getInstance().setVideoCfg(cfg);
					}
				});
	}

	private void showVideoFpsDialog() {
		int curFps = CloudroomVideoMeeting.getInstance().getVideoCfg().fps;
		showSingleChoiceDialog(getString(R.string.video_fps),
				getStringArray(R.array.fps), "" + curFps, new SelectListener() {

					@Override
					public void onSelect(int index, String item) {
						int fps = Integer.parseInt(item);
						VideoCfg cfg = CloudroomVideoMeeting.getInstance()
								.getVideoCfg();
						cfg.fps = fps;
						cfg.maxbps = -1;
						CloudroomVideoMeeting.getInstance().setVideoCfg(cfg);
					}
				});
	}

	// ---------------------- IM Begin ----------------------

	private ListView mIMListView = null;
	private View mIMInputBar = null;
	private EditText mIMInputET = null;
	private IMAdapter mIMAdapter = null;

	private void showImMsg(boolean show) {
		if (show) {
			mIMInputBar.setVisibility(View.VISIBLE);
			mIMInputET.requestFocusFromTouch();
			InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.showSoftInput(mIMInputET, InputMethodManager.SHOW_FORCED);
		} else {
			InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.hideSoftInputFromWindow(mIMInputET.getWindowToken(), 0);
			mIMInputBar.setVisibility(View.GONE);
		}
	}

	// 发送聊天消息
	private void sendMsg() {
		// 获取输入框内容
		String text = mIMInputET.getEditableText().toString();
		// 检查内容是否为空
		if (TextUtils.isEmpty(text)) {
			VideoSDKHelper.getInstance().showToast(R.string.send_null);
			return;
		}
		HashMap<String, String> map = new HashMap<String, String>();
		map.put("CmdType", "IM");
		map.put("IMMsg", text);
		Gson gson = new Gson();
		String jsonStr = gson.toJson(map);

		// 发送聊天消息
		CloudroomVideoMeeting.getInstance().sendMeetingCustomMsg(jsonStr, jsonStr);
		// 清空输入框
		mIMInputET.setText("");
	}

	@SuppressLint("InflateParams")
	private class IMAdapter extends ArrayAdapter<IMmsg> {

		public IMAdapter(Context context, int textViewResourceId,
				List<IMmsg> objects) {
			super(context, textViewResourceId, objects);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = getLayoutInflater().inflate(
						R.layout.layout_immsg_item, null);
			}
			IMmsg info = getItem(position);
			updateItemView(convertView, info);
			return convertView;
		}

		@SuppressWarnings("unused")
		public void updateItemView(int position, IMmsg info) {
			int firstVisiblePosition = mIMListView.getFirstVisiblePosition();
			int lastVisiblePosition = mIMListView.getLastVisiblePosition();
			if (position >= firstVisiblePosition
					&& position <= lastVisiblePosition) {
				View view = mIMListView.getChildAt(position
						- firstVisiblePosition);
				updateItemView(view, info);
			}
		}

		public void updateItemView(View convertView, IMmsg info) {
			TextView nameTV = (TextView) convertView.findViewById(R.id.tv_name);
			TextView msgTV = (TextView) convertView
					.findViewById(R.id.tv_msg_text);

			msgTV.setText(info.text);
			String nickName = CloudroomVideoMeeting.getInstance().getNickName(
					info.fromUserID);
			nameTV.setText(nickName);
			nameTV.setVisibility(TextUtils.isEmpty(nickName) ? View.GONE
					: View.VISIBLE);
		}
	}

	// ---------------------- IM End ----------------------
}
