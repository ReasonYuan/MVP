package com.hp.android.halcyon.widgets;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;

public class LoadingView extends FrameLayout {

	private int mDuration = 250;
	
	private TextView mMsgText;

	public LoadingView(Context context) {
		super(context);
		init();
	}

	public LoadingView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public LoadingView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	public void init() {
		View v = LayoutInflater.from(getContext()).inflate(
				R.layout.view_loading_view, null);
		addView(v);

		mMsgText = (TextView) findViewById(R.id.tv_loading_msg);
	}

	public void setMessage(String msg) {
		mMsgText.setText(msg);
	}
	
	public void setDuration(int duration){
		mDuration = duration;
	}

	public void show() {
		setVisibility(View.VISIBLE);
		TranslateAnimation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF, 0.0f,
				Animation.RELATIVE_TO_SELF, -1.0f, Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(mDuration);
		startAnimation(animation);
	}

	public void dismiss() {
		setVisibility(View.GONE);
		TranslateAnimation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0f, Animation.RELATIVE_TO_SELF, 0f,
				Animation.RELATIVE_TO_SELF, 0f, Animation.RELATIVE_TO_SELF, -1f);
		animation.setDuration(mDuration);
		startAnimation(animation);
	}
}
