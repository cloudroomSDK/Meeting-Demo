package com.example.main;

import java.util.ArrayList;

import android.content.Context;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.cloudroom.cloudroomvideosdk.CRMeetingCallback;
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting;
import com.cloudroom.cloudroomvideosdk.model.CRVIDEOSDK_ERR_DEF;
import com.cloudroom.cloudroomvideosdk.model.UsrVideoId;
import com.cloudroom.cloudroomvideosdk.model.VIDEO_WALL_MODE;
import com.cloudroom.cloudroomvideosdk.model.VSTATUS;
import com.example.meetingdemo.R;
import com.examples.tool.CRLog;

public class VideoWallView extends RelativeLayout {

	private static final String TAG = "VideoWallView";

	private VIDEO_WALL_MODE mVideoWallMode = VIDEO_WALL_MODE.VLO_WALL2;
	ArrayList<VideoView> mVideoViews = new ArrayList<VideoView>();
	private CRMeetingCallback mCRMeetingCallback = new CRMeetingCallback() {

		@Override
		public void defVideoChanged(String userID, short videoID) {
			// TODO Auto-generated method stub
			// 更新观看视频
			updateWatchVideos();
		}

		@Override
		public void enterMeetingRslt(CRVIDEOSDK_ERR_DEF code) {
			// TODO Auto-generated method stub
			if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
				return;
			}
			mBInMeeting = true;
			// 更新观看视频
			updateWatchVideos();
		}

		@Override
		public void notifyVideoWallMode(VIDEO_WALL_MODE wallMode) {
			// TODO Auto-generated method stub
		}

		@Override
		public void userEnterMeeting(String userID) {
			// TODO Auto-generated method stub
			// 更新观看视频
			updateWatchVideos();
		}

		@Override
		public void userLeftMeeting(String userID) {
			// TODO Auto-generated method stub
			// 更新观看视频
			updateWatchVideos();
		}

		@Override
		public void videoDevChanged(String userID) {
			// TODO Auto-generated method stub
			// 更新观看视频
			updateWatchVideos();
		}

		@Override
		public void videoStatusChanged(String userID, VSTATUS oldStatus,
				VSTATUS newStatus) {
			// TODO Auto-generated method stub
			// 更新观看视频
			updateWatchVideos();
		}
	};

	private boolean mBInMeeting = false;

	public VideoWallView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		init();
	}

	public VideoWallView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		init();
	}

	private void init() {
		resetVideoWallLayout();
		CloudroomVideoMeeting.getInstance()
				.registerCallback(mCRMeetingCallback);
	}
	
	private static final int MSG_RESET_LAYOUT = 0;
	private Handler mMainHandler = new Handler(new Callback() {
		
		@Override
		public boolean handleMessage(Message msg) {
			// TODO Auto-generated method stub
			switch (msg.what) {
			case MSG_RESET_LAYOUT:
				resetVideoWallLayout();
				break;
			default:
				break;
			}
			return false;
		}
	});

	private View mViewContainer = null;

	private void resetVideoWallLayout() {
		mMainHandler.removeMessages(MSG_RESET_LAYOUT);
		int layoutId = 0;
		switch (mVideoWallMode) {
		case VLO_1v1_M:
		case VLO_WALL1_M:
		case VLO_WALL2:
			layoutId = R.layout.layout_videowall_2;
			break;
		case VLO_WALL4:
			layoutId = R.layout.layout_videowall_4;
			break;
		case VLO_WALL16:
		case VLO_WALL25:
			layoutId = R.layout.layout_videowall_16;
			break;
		default:
			layoutId = R.layout.layout_videowall_9;
			break;
		}
		mVideoViews.clear();
		removeAllViews();

		mViewContainer = LayoutInflater.from(getContext()).inflate(layoutId,
				null);
		LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT);
		params.addRule(RelativeLayout.CENTER_VERTICAL, 1);
		params.addRule(RelativeLayout.CENTER_HORIZONTAL, 1);
		addView(mViewContainer, params);
		CRLog.debug(TAG, "addVideoViewToList mode:" + mVideoWallMode);
		addVideoViewToList(mViewContainer);
		if (mBInMeeting) {
			// 更新观看视频
			updateWatchVideos();
		}
		updateShowSize();
	}

	public void resetSufaceView() {
		for (VideoView view : mVideoViews) {
			view.resetSufaceView();
		}
	}

	private void addVideoViewToList(View view) {
		if (view instanceof VideoView) {
			mVideoViews.add((VideoView) view);
			return;
		}
		if (view instanceof ViewGroup) {
			ViewGroup groupView = (ViewGroup) view;
			int count = groupView.getChildCount();
			for (int i = 0; i < count; i++) {
				addVideoViewToList(groupView.getChildAt(i));
			}
		}
	}

	public VIDEO_WALL_MODE getVideoWallMode() {
		return mVideoWallMode;
	}

	public void setVideoWallMode(VIDEO_WALL_MODE videoWallMode) {
		VIDEO_WALL_MODE mode = VIDEO_WALL_MODE.VLO_WALL6_M;
		switch (videoWallMode) {
		case VLO_1v1_M:
		case VLO_WALL1_M:
		case VLO_WALL2:
			mode = VIDEO_WALL_MODE.VLO_WALL2;
			break;
		case VLO_WALL4:
			mode = VIDEO_WALL_MODE.VLO_WALL4;
			break;
		case VLO_WALL16:
		case VLO_WALL25:
			mode = VIDEO_WALL_MODE.VLO_WALL16;
			break;
		default:
			mode = VIDEO_WALL_MODE.VLO_WALL9;
			break;
		}
		if (mVideoWallMode == mode) {
			return;
		}
		this.mVideoWallMode = mode;
		mMainHandler.removeMessages(MSG_RESET_LAYOUT);
		mMainHandler.sendEmptyMessageDelayed(MSG_RESET_LAYOUT, 200);
	}

	private void updateWatchVideos() {
		// 更新观看视频
		ArrayList<UsrVideoId> watchableVideos = CloudroomVideoMeeting
				.getInstance().getWatchableVideos();

		int watchableSize = watchableVideos.size();
		VIDEO_WALL_MODE mode = VIDEO_WALL_MODE.VLO_WALL2;
		if (watchableSize > 9) {
			mode = VIDEO_WALL_MODE.VLO_WALL16;
		} else if (watchableSize > 4) {
			mode = VIDEO_WALL_MODE.VLO_WALL9;
		} else if (watchableSize > 2) {
			mode = VIDEO_WALL_MODE.VLO_WALL4;
		}
		if (mVideoWallMode != mode) {
			setVideoWallMode(mode);
		}

		for (VideoView videoView : mVideoViews) {
			UsrVideoId usrVideoId = videoView.getUsrVideoId();
			if (!watchableVideos.contains(usrVideoId)) {
				videoView.setUsrVideoId(null);
			} else {
				watchableVideos.remove(usrVideoId);
			}
		}

		for (UsrVideoId usrVideoId : watchableVideos) {
			VideoView videoView = getUnWatchVideoView();
			if (videoView == null) {
				break;
			}
			videoView.setUsrVideoId(usrVideoId);
		}
	}

	private VideoView getUnWatchVideoView() {
		for (VideoView videoView : mVideoViews) {
			if (videoView.getUsrVideoId() == null) {
				return videoView;
			}
		}
		return null;
	}

	private void updateShowSize() {
		float whRate = 1.0f;
		if (mVideoWallMode == VIDEO_WALL_MODE.VLO_WALL2) {
			whRate = 2.0f;
		}
		int parentWidth = getWidth();
		int parentHeight = getHeight();

		int width = parentWidth;
		int height = parentHeight;
		if ((float) parentWidth / parentHeight > whRate) {
			width = (int) (parentHeight * whRate);
		} else {
			height = (int) (parentWidth / whRate);
		}
		if (width == getWidth() && height == getHeight()) {
			return;
		}
		int left = (parentWidth - width) / 2;
		int top = (parentHeight - height) / 2;
		mUserLayout = true;
		LayoutParams params = (LayoutParams) mViewContainer.getLayoutParams();
		params.width = width;
		params.height = height;
		mViewContainer.setLayoutParams(params);
		mUserLayout = false;
		Log.d(TAG, "updateShowSize left:" + left + " top:" + top + " width:"
				+ width + " height:" + height);
	}

	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh) {
		// TODO Auto-generated method stub
		super.onSizeChanged(w, h, oldw, oldh);
		Log.d(TAG, "onSizeChanged w:" + w + " h:" + h + " oldw:" + oldw
				+ " oldh:" + oldh);
		updateShowSize();
	}

	private boolean mUserLayout = false;

	@Override
	protected void onLayout(boolean changed, int left, int top, int right,
			int bottom) {
		// TODO Auto-generated method stub
		super.onLayout(changed, left, top, right, bottom);
		Log.d(TAG, "onLayout left:" + left + " top:" + top + " right:" + right
				+ " bottom:" + bottom);
		if (changed && !mUserLayout) {
			updateShowSize();
		}
	}
}
