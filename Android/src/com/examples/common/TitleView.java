package com.examples.common;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.example.meetingdemo.R;

public class TitleView extends RelativeLayout {

	private TextView mTitleTV = null;
	private ImageView mTitleLeftIV = null;
	private ImageView mTitleRightIV = null;
	private TextView mTitleLeftTV = null;
	private TextView mTitleRightTV = null;

	public TitleView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		LayoutInflater.from(context).inflate(R.layout.layout_titlebar, this);

		mTitleTV = (TextView) findViewById(R.id.titlebar_tv_title);
		mTitleLeftIV = (ImageView) findViewById(R.id.titlebar_iv_left);
		mTitleRightIV = (ImageView) findViewById(R.id.titlebar_iv_right);
		mTitleLeftTV = (TextView) findViewById(R.id.titlebar_tv_left);
		mTitleRightTV = (TextView) findViewById(R.id.titlebar_tv_right);

		TypedArray typedArray = context.obtainStyledAttributes(attrs,
				R.styleable.TitleView);
		if (typedArray != null) {
			int titleText = typedArray.getResourceId(
					R.styleable.TitleView_titlebar_title_text, 0);
			setTitleTextResId(titleText);

			int leftBtnSrc = typedArray.getResourceId(
					R.styleable.TitleView_titlebar_left_btn_src, 0);
			setLeftBtnImgResId(leftBtnSrc);

			int rightBtnSrc = typedArray.getResourceId(
					R.styleable.TitleView_titlebar_right_btn_src, 0);
			setRightBtnImgResId(rightBtnSrc);

			int leftBtnText = typedArray.getResourceId(
					R.styleable.TitleView_titlebar_left_btn_text, 0);
			setLeftBtnTextResId(leftBtnText);

			int rightBtnText = typedArray.getResourceId(
					R.styleable.TitleView_titlebar_right_btn_text, 0);
			setRightBtnTextResId(rightBtnText);

			typedArray.recycle();
		}
	}

	public void setTitleText(String title) {
		mTitleTV.setText(title);
	}

	public void setTitleTextResId(int resId) {
		if (resId > 0) {
			mTitleTV.setText(resId);
		} else {
			mTitleTV.setText(null);
		}
	}

	public void setLeftBtnImgResId(int resId) {
		if (resId > 0) {
			mTitleLeftIV.setVisibility(View.VISIBLE);
			mTitleLeftIV.setImageResource(resId);
		} else {
			mTitleLeftIV.setVisibility(View.INVISIBLE);
		}
	}

	public void setLeftBtnTextResId(int resId) {
		if (resId > 0) {
			mTitleLeftTV.setVisibility(View.VISIBLE);
			mTitleLeftTV.setText(resId);
		} else {
			mTitleLeftTV.setVisibility(View.INVISIBLE);
		}
	}

	public void setRightBtnImgResId(int resId) {
		if (resId > 0) {
			mTitleRightIV.setVisibility(View.VISIBLE);
			mTitleRightIV.setImageResource(resId);
		} else {
			mTitleRightIV.setVisibility(View.INVISIBLE);
		}
	}

	public void setRightBtnTextResId(int resId) {
		if (resId > 0) {
			mTitleRightTV.setVisibility(View.VISIBLE);
			mTitleRightTV.setText(resId);
		} else {
			mTitleRightTV.setVisibility(View.INVISIBLE);
		}
	}

}
