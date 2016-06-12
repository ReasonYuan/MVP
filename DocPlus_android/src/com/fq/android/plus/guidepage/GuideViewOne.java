package com.fq.android.plus.guidepage;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.fq.android.plus.R;

public class GuideViewOne extends LinearLayout {
	private ImageView year;
	private ImageView time;
	private ImageView text;
	private ImageView earth;
	private ImageView cloud1, cloud2, cloud3;
	private ImageView patientLibrary;
	private LinearLayout mView;
	private boolean isFirstShow = true;
	private AnimationFinishCallBack callBack;

	public GuideViewOne(Context context,AnimationFinishCallBack callBack) {
		super(context);
		this.callBack = callBack;
		init();
	}
	public GuideViewOne(Context context) {
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
		} else {
			text.clearAnimation();
			year.clearAnimation();
			time.clearAnimation();
			cloud1.clearAnimation();
			cloud2.clearAnimation();
			cloud3.clearAnimation();
			earth.clearAnimation();
			patientLibrary.clearAnimation();
			text.setVisibility(View.VISIBLE);
			year.setVisibility(View.VISIBLE);
			time.setVisibility(View.VISIBLE);
			cloud1.setVisibility(View.VISIBLE);
			cloud2.setVisibility(View.VISIBLE);
			cloud3.setVisibility(View.VISIBLE);
			earth.setVisibility(View.VISIBLE);
			patientLibrary.setVisibility(View.VISIBLE);
		}
	}

	public GuideViewOne(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	private void init() {
		mView = (LinearLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.guide1, null);
		year = (ImageView) mView.findViewById(R.id.year);
		time = (ImageView) mView.findViewById(R.id.time);
		text = (ImageView) mView.findViewById(R.id.text);
		earth = (ImageView) mView.findViewById(R.id.earth);
		cloud1 = (ImageView) mView.findViewById(R.id.cloud1);
		cloud2 = (ImageView) mView.findViewById(R.id.cloud2);
		cloud3 = (ImageView) mView.findViewById(R.id.cloud3);
		patientLibrary = (ImageView) mView.findViewById(R.id.patientLibrary);
		LinearLayout.LayoutParams mParams = new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.MATCH_PARENT,
				LinearLayout.LayoutParams.MATCH_PARENT);
		show();
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
				if(isFirstShow){
					earthAniamtion();
				}
			}
		});
	}

	private void earthAniamtion() {
		ScaleAnimation scale = new ScaleAnimation(0f, 1f, 0f, 1f,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		scale.setDuration(800);
		earth.startAnimation(scale);
		earth.setVisibility(View.VISIBLE);
		scale.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
					cloudOneAnimation();
					cloudTwoAnimation();
					cloudThreeAnimation();
				}
			}
		});
	}

	private void cloudOneAnimation() {
		Animation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, -0.5f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, 0.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(800);
		Animation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(500);
		AnimationSet animationSet = new AnimationSet(true);
		animationSet.addAnimation(animation);
		animationSet.addAnimation(alpha);
		animationSet.setDuration(800);
		cloud1.startAnimation(animationSet);
		cloud1.setVisibility(View.VISIBLE);
		animation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
					cloud1.startAnimation(cloudAnimation(900));
					patientLibraryAnimation();
				}
			}
		});

	}

	private void cloudTwoAnimation() {
		Animation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, 0.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(800);
		cloud2.startAnimation(animation);
		cloud2.setVisibility(View.VISIBLE);
		animation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
					cloud2.startAnimation(cloudAnimation(1000));
				}
			}
		});

	}

	private void cloudThreeAnimation() {
		Animation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, 0.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(800);
		cloud3.startAnimation(animation);
		cloud3.setVisibility(View.VISIBLE);
		animation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if(isFirstShow){
					cloud3.startAnimation(cloudAnimation(1300));
				}
			}
		});
	}

	private void patientLibraryAnimation() {
		Animation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, -1.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, 1.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(800);
		Animation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		AnimationSet animationSet = new AnimationSet(true);
		animationSet.addAnimation(animation);
		animationSet.addAnimation(alpha);
		patientLibrary.startAnimation(animationSet);
		patientLibrary.setVisibility(View.VISIBLE);
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
	
	private Animation cloudAnimation(int time){
		Animation anim = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0f,
				Animation.RELATIVE_TO_SELF, 0f,
				Animation.RELATIVE_TO_SELF, 0.0f,
				Animation.RELATIVE_TO_SELF, 0.2f);
		anim.setDuration(time);
		anim.setRepeatCount(-1);
		anim.setRepeatMode(Animation.REVERSE);
		return anim;
	}
	
	public interface AnimationFinishCallBack {
		public void onFinishCallback();
	}
}
