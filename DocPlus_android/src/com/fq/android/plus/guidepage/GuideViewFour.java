package com.fq.android.plus.guidepage;

import android.app.Activity;
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
import android.widget.ImageButton;
import android.widget.ImageView;

import com.fq.android.plus.R;

public class GuideViewFour extends FrameLayout {

	private ImageView text;
	private ImageView title;
	private ImageView feiji;
	private ImageView cloud1, cloud2, cloud3;
	private ImageButton startBtn;
	private FrameLayout mView;
	private boolean isFirstShow = true;

	public GuideViewFour(Context context) {
		super(context);
		init();
	}

	public void setFirstShow(boolean isFirstShow) {
		this.isFirstShow = isFirstShow;
	}

	public void show() {
		if (isFirstShow) {
			titleAnimation();
		} else {
			text.clearAnimation();
			title.clearAnimation();
			feiji.clearAnimation();
			cloud1.clearAnimation();
			cloud2.clearAnimation();
			cloud3.clearAnimation();
			startBtn.clearAnimation();
			text.setVisibility(View.VISIBLE);
			title.setVisibility(View.VISIBLE);
			cloud1.setVisibility(View.VISIBLE);
			cloud2.setVisibility(View.VISIBLE);
			cloud3.setVisibility(View.VISIBLE);
			startBtn.setVisibility(View.VISIBLE);
		}
	}

	public GuideViewFour(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public interface OnStartListener{
		public void onStart();
	}
	
	private OnStartListener onStartListener;
	
	public void setOnStartListener(OnStartListener onStartListener){
		this.onStartListener = onStartListener;
	}
	
	private void init() {
		mView = (FrameLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.guide4, null);
		text = (ImageView) mView.findViewById(R.id.text);
		feiji = (ImageView) mView.findViewById(R.id.feiji);
		title = (ImageView) mView.findViewById(R.id.title);
		cloud1 = (ImageView) mView.findViewById(R.id.cloud1);
		cloud2 = (ImageView) mView.findViewById(R.id.cloud2);
		cloud3 = (ImageView) mView.findViewById(R.id.cloud3);
		startBtn = (ImageButton) mView.findViewById(R.id.start_button);
		startBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				((Activity)getContext()).finish();
				onStartListener.onStart();
			}
		});
		FrameLayout.LayoutParams mParams = new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.MATCH_PARENT,
				FrameLayout.LayoutParams.MATCH_PARENT);
		addView(mView);
		mView.setLayoutParams(mParams);
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
				if (isFirstShow) {
					textAnimation();
				}
			}
		});
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
		text.setVisibility(View.VISIBLE);
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
					cloudThreeAnimation();
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
				if (isFirstShow) {
					Animation anim = new TranslateAnimation(
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0.2f);
					anim.setDuration(1000);
					anim.setRepeatCount(-1);
					anim.setRepeatMode(Animation.REVERSE);
					cloud3.startAnimation(anim);
					cloudOneAnimation();
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
		cloud1.startAnimation(animation);
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
				if (isFirstShow) {
					Animation anim = new TranslateAnimation(
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0.2f);
					anim.setDuration(900);
					anim.setRepeatCount(-1);
					anim.setRepeatMode(Animation.REVERSE);
					cloud1.startAnimation(anim);
					cloudTwoAnimation();
					startBtnAnimation();
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
				if (isFirstShow) {
					Animation anim = new TranslateAnimation(
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0f,
							Animation.RELATIVE_TO_SELF, 0.2f);
					anim.setDuration(1000);
					anim.setRepeatCount(-1);
					anim.setRepeatMode(Animation.REVERSE);
					cloud2.startAnimation(anim);
				}

			}
		});
	}

	private void startBtnAnimation() {
		Animation animation = new AlphaAnimation(0, 1);
		animation.setDuration(800);
		startBtn.startAnimation(animation);
		startBtn.setVisibility(View.VISIBLE);
		animation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation arg0) {

			}

			@Override
			public void onAnimationRepeat(Animation arg0) {

			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				if (isFirstShow) {
					feijiAnimation();
				}
			}
		});
	}

	private void feijiAnimation() {
		//tox：0.6f，否则不能完全飞出去
		Animation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT, -0.6f,
				Animation.RELATIVE_TO_PARENT, 0.6f, Animation.RELATIVE_TO_PARENT,
				0.25f, Animation.RELATIVE_TO_PARENT, -0.25f);
		animation.setDuration(2000);
		feiji.startAnimation(animation);
	}
}
