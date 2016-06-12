package com.hp.halcyon.widgets.main;

import java.util.ArrayList;

import android.view.animation.Transformation;

public class AnimateSet extends Animate {
	
	private ArrayList<Animate> mAnimates;

	public AnimateSet(int duration) {
		super( duration);
		mAnimates = new ArrayList<Animate>();
	}

	/**
	 * 
	 * @param animate animate duration will be AnimateSet's duration
	 * @return
	 */
	public AnimateSet addAnimate(Animate animate){
		if(animate != null && !mAnimates.contains(animate)) {
			mAnimates.add(animate);
			animate.setDuration(mDuration);
		}
		return this;
	}
	
	public void start() {
		mStartTime = System.currentTimeMillis();
		mEndTime = mStartTime + mDuration;
		mIsAnimationEnd = false;
		for (int i = 0; i < mAnimates.size(); i++) {
			Animate animate = mAnimates.get(i);
			animate.mStartTime = mStartTime;
			animate.mEndTime = mEndTime;
		}
		if (mAnimateListener != null)
			mAnimateListener.onAnimationStart(this);
	}
	
	@Override
	public Transformation getTransformation(FQView v) {
		if(!mIsAnimationEnd){
			mtTransformation.clear();
			long currentTime = System.currentTimeMillis();
			float interpolatedTime = (currentTime - mStartTime) / (float) mDuration;
			getTransformation(v, interpolatedTime);
		}
		return mtTransformation;
	}
	
	@Override
	public Transformation getTransformation(FQView v, float interpolatedTime) {
		if(!mIsAnimationEnd){
			mtTransformation.clear();
			if (interpolatedTime >= 1) {
				interpolatedTime = 1;
				mIsAnimationEnd = true;
			}
			for (int i = 0; i < mAnimates.size(); i++) {
				Animate animate = mAnimates.get(i);
				Transformation transformation = animate.getTransformation(v,interpolatedTime);
				mtTransformation.compose(transformation);
			}
			mInterpolatedTime = interpolatedTime;
		}
		return mtTransformation;
	}
	
	@Override
	public void animateEnd() {
		super.animateEnd();
		for (int i = 0; i < mAnimates.size(); i++) {
			Animate animate = mAnimates.get(i);
			animate.animateEnd();
		}
	}
	
	@Override
	public AnimateSet recover() {
		AnimateSet set = new AnimateSet((int) (mDuration*mInterpolatedTime));
		for (int i = 0; i < mAnimates.size(); i++) {
			Animate animate = mAnimates.get(i);
			set.addAnimate(animate.recover());
		}
		return set;
	}
}
