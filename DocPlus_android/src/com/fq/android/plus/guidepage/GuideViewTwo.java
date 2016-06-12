package com.fq.android.plus.guidepage;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.LinearInterpolator;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.fq.android.plus.R;
import com.fq.android.plus.guidepage.GuideViewOne.AnimationFinishCallBack;

public class GuideViewTwo extends LinearLayout {
	private ImageView title;
	private ImageView image;
	private ImageView text;
	private ImageView time;
	private ImageView year;
	private LinearLayout mView;
	private boolean isFirstShow = true;
	private AnimationFinishCallBack callBack;
	public GuideViewTwo(Context context,AnimationFinishCallBack callBack) {
		super(context);
		this.callBack = callBack;
		init();
	}
	public GuideViewTwo(Context context) {
		super(context);
		init();
	}
	public void setFirstShow(boolean isFirstShow) {
		this.isFirstShow = isFirstShow;
	}
	public void show() {
		if (isFirstShow) {
			yearAnimation();
			textAnimation();
		}else{
			text.clearAnimation();
			year.clearAnimation();
			time.clearAnimation();
			title.clearAnimation();
			image.clearAnimation();
			text.setVisibility(View.VISIBLE);
			title.setVisibility(View.VISIBLE);
			image.setVisibility(View.VISIBLE);
			year.setVisibility(View.VISIBLE);
			time.setVisibility(View.VISIBLE);
		}
	}
	private void init() {
		mView = (LinearLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.guide2, null);
		year = (ImageView) mView.findViewById(R.id.year);
		time = (ImageView) mView.findViewById(R.id.time);
		text = (ImageView) mView.findViewById(R.id.text);
		image = (ImageView) mView.findViewById(R.id.image);
		title = (ImageView) mView.findViewById(R.id.title);
		LinearLayout.LayoutParams mParams = new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.MATCH_PARENT,
				LinearLayout.LayoutParams.MATCH_PARENT);
		addView(mView);
		mView.setLayoutParams(mParams);
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
	}

	private void textAnimation() {
		AnimationSet animationSet = new AnimationSet(true);
		TranslateAnimation translateAnimation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, -0.5f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		translateAnimation.setDuration(800);
		animationSet.addAnimation(translateAnimation);
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		animationSet.addAnimation(alpha);
		animationSet.setFillAfter(true);
		animationSet.setFillEnabled(true);
		animationSet.setDuration(800);
		text.startAnimation(animationSet);
		animationSet.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
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
				if(isFirstShow){
					imageAnimation();
				}
			}
		});
	}

	private void imageAnimation() {
		AnimationSet animationSet = new AnimationSet(true);
		Animation animation = new Rotate3dAnimation(-180, 0,
				image.getWidth() / 2.f, image.getHeight() / 2.f, 0f, true);
		animation.setDuration(3000);
		animation.setFillAfter(false);
		LinearInterpolator lir = new LinearInterpolator();
		animation.setInterpolator(lir);
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(2200);
		animationSet.addAnimation(alpha);
		animationSet.addAnimation(animation);
		image.startAnimation(animationSet);
		image.setVisibility(View.VISIBLE);
		alpha.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
					titleAnimation();
				}
			}
		});
	}

	private void titleAnimation() {
		AnimationSet animationSet = new AnimationSet(true);
		TranslateAnimation translateAnimation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, -0.5f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		translateAnimation.setDuration(800);
		animationSet.addAnimation(translateAnimation);
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		animationSet.addAnimation(alpha);
		animationSet.setFillAfter(true);
		animationSet.setFillEnabled(true);
		animationSet.setDuration(800);
		title.startAnimation(animationSet);
		title.setVisibility(View.VISIBLE);
		animationSet.setAnimationListener(new AnimationListener() {
			
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
