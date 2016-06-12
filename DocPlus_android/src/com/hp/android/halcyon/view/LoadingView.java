package com.hp.android.halcyon.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.AnimationDrawable;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;

import com.fq.android.plus.R;

public class LoadingView extends FrameLayout{

	private ImageView imgLoading;
	private AnimationDrawable animation;
	private int loadingAnim;
	
	
	public LoadingView(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.LoadingView);
		loadingAnim = ta.getResourceId(R.styleable.LoadingView_loading_anim, R.anim.loading);
		ta.recycle();
		imgLoading = new ImageView(context);
		LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		imgLoading.setScaleType(ScaleType.CENTER_CROP);
		imgLoading.setBackgroundResource(loadingAnim);
		addView(imgLoading,params);
		animation = (AnimationDrawable) imgLoading.getBackground();
		animation.setOneShot(false);
	}

	public void startAnim(){
		animation.start();
	}
	
	public void stopAnim(){
		if (animation.isRunning()) {
			animation.stop();
		}
	}
}
