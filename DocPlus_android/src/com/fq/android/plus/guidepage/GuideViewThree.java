package com.fq.android.plus.guidepage;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.android.plus.guidepage.GuideViewOne.AnimationFinishCallBack;

public class GuideViewThree extends FrameLayout {

	private ImageView phone;
	private ImageView background;
	private ImageView time;
	private ImageView year;
	private ImageView title;
	private FrameLayout mView;
	private FrameLayout mContainer;
	private boolean isFirstShow = true;
	private AnimationFinishCallBack callBack;
	public GuideViewThree(Context context,AnimationFinishCallBack callBack) {
		super(context);
		this.callBack = callBack;
		init();
	}
	public GuideViewThree(Context context) {
		super(context);
		init();
	}

	public void setFirstShow(boolean isFirstShow) {
		this.isFirstShow = isFirstShow;
	}

	public void show() {
		if (isFirstShow) {
			yearAnimation();
			backgroundAnimation();
			titleAnimation();
		} else {
			phone.clearAnimation();
			year.clearAnimation();
			time.clearAnimation();
			background.clearAnimation();
			mContainer.clearAnimation();
			phone.setVisibility(View.VISIBLE);
			background.setVisibility(View.VISIBLE);
			time.setVisibility(View.VISIBLE);
			year.setVisibility(View.VISIBLE);
			title.setVisibility(View.VISIBLE);
			mContainer.setVisibility(View.VISIBLE);
		}
	}

	public GuideViewThree(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	private void init() {
		mView = (FrameLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.guide3, null);
		year = (ImageView) mView.findViewById(R.id.year);
		time = (ImageView) mView.findViewById(R.id.time);
		background = (ImageView) mView.findViewById(R.id.background);
		phone = (ImageView) mView.findViewById(R.id.phone);
		mContainer = (FrameLayout) mView.findViewById(R.id.fl);
		title = (ImageView) mView.findViewById(R.id.title);
		FrameLayout.LayoutParams mParams = new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.MATCH_PARENT,
				FrameLayout.LayoutParams.MATCH_PARENT);
		addView(mView);
		mView.setLayoutParams(mParams);
	}

	private void backgroundAnimation() {
		AnimationSet animationSet = new AnimationSet(true);
		TranslateAnimation translateAnimation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_PARENT, -1.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		translateAnimation.setDuration(1200);
		animationSet.addAnimation(translateAnimation);
		AlphaAnimation alpha = new AlphaAnimation(0.0f, 1);
		alpha.setDuration(1200);
		animationSet.addAnimation(alpha);
		animationSet.setFillAfter(true);
		animationSet.setFillEnabled(true);
		animationSet.setDuration(1200);
		background.startAnimation(animationSet);
		background.setVisibility(View.VISIBLE);
	}
	private void titleAnimation(){
		AlphaAnimation alpha = new AlphaAnimation(0.0f, 1);
		alpha.setDuration(1000);
		title.startAnimation(alpha);
		title.setVisibility(View.VISIBLE);
	}

	private void yearAnimation() {
		AnimationSet animationSet = new AnimationSet(true);
		TranslateAnimation translateAnimation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_PARENT, 0.5f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		translateAnimation.setDuration(800);
		animationSet.addAnimation(translateAnimation);
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		animationSet.addAnimation(alpha);
		animationSet.setFillAfter(true);
		animationSet.setFillEnabled(true);
		animationSet.setDuration(800);
		year.startAnimation(animationSet);
		year.setVisibility(View.VISIBLE);
		animationSet.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if (isFirstShow) {
					timeAnimation();
				}
			}
		});
	}

	private void timeAnimation() {
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		time.startAnimation(alpha);
		time.setVisibility(View.VISIBLE);
		alpha.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if (isFirstShow) {
					phoneAnimation();
				}
			}
		});
	}

	private void phoneAnimation() {
		Animation trAniamAnimation1 = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, 1.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		trAniamAnimation1.setDuration(1200);
		Animation trAniamAnimation2 = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, -1.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		trAniamAnimation2.setDuration(1200);
		mContainer.startAnimation(trAniamAnimation2);
		phone.startAnimation(trAniamAnimation1);
		phone.setVisibility(View.VISIBLE);
		trAniamAnimation2.setAnimationListener(new AnimationListener() {
			
			@Override
			public void onAnimationStart(Animation arg0) {
				
			}
			
			@Override
			public void onAnimationRepeat(Animation arg0) {
				
			}
			
			@Override
			public void onAnimationEnd(Animation arg0) {
//				callBack.onFinishCallback();
			}
		});
		
	}
}
