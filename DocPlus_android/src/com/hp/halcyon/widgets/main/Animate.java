package com.hp.halcyon.widgets.main;

import android.graphics.Matrix;
import android.view.animation.Transformation;

public class Animate {

	public static interface AnimateListener {

		void onAnimationStart(Animate animate);

		void onAnimationEnd(Animate animate);
	}

	public float mScaleXFrom, mScaleXTo,mScaleYFrom, mScaleYTo, mDegreeFrom, mDegreeTo;

	public float mOffsetToX, mOffsetToY, mOffsetFromX, mOffsetFromY;

	public int mDuration;

	public long mStartTime, mEndTime;

	public boolean mIsAnimationEnd = false;

	protected AnimateListener mAnimateListener;

	protected Transformation mtTransformation;

	public float mInterpolatedTime = 0;

	public Animate(int duration) {
		this(1.f, 1.f, 0, 0, duration);
	}

	/**
	 * scale animation
	 */
	public Animate(float scaleFrom, float scaleTo, int duration) {
		this(scaleFrom, scaleTo, 0, 0, duration);
	}

	/**
	 * scale and degree animation
	 */
	public Animate(float scaleFrom, float scaleTo, float degreeFrom, float degreeTo, int duration) {
		mScaleXFrom = scaleFrom;
		mScaleXTo = scaleTo;
		mScaleYFrom = scaleFrom;
		mScaleYTo = scaleTo;
		mDegreeFrom = degreeFrom;
		mDegreeTo = degreeTo;
		mDuration = duration;
		mOffsetFromX = mOffsetFromY = 0;
		mOffsetToX = mOffsetToY = 0;
		init();
	}
	
	/**
	 * scale and degree animation
	 */
	public Animate(float scaleXFrom, float scaleXTo,float scaleYFrom, float scaleYTo, float offsetX, float offsetY, int duration) {
		mScaleXFrom = scaleXFrom;
		mScaleXTo = scaleXTo;
		mScaleYFrom = scaleYFrom;
		mScaleYTo = scaleYTo;
		mDegreeFrom = 0;
		mDegreeTo = 0;
		mDuration = duration;
		mOffsetFromX = mOffsetFromY = 0;
		mOffsetToX = offsetX;
		mOffsetToY = offsetY;
		init();
	}

	/**
	 * translate animation
	 */
	public Animate setOffset(float offsetX, float offsetY) {
		return setOffset(0, offsetX, 0, offsetY);
	}
	
	/**
	 * translate animation
	 */
	public Animate setOffset(float xFrom ,float xTo, float yFrom ,float yTo) {
		mOffsetFromX = xFrom;
		mOffsetFromY = yFrom;
		mOffsetToX = xTo;
		mOffsetToY = yTo;
		return this;
	}

	private void init() {
		mtTransformation = new Transformation();
	}

	public void setDuration(int duration) {
		mDuration = duration;
	}

	public void start() {
		mInterpolatedTime = 0;
		mStartTime = System.currentTimeMillis();
		mEndTime = mStartTime + mDuration;
		mIsAnimationEnd = false;
		if (mAnimateListener != null)
			mAnimateListener.onAnimationStart(this);
	}

	public Transformation getTransformation(FQView v) {
		if (!mIsAnimationEnd) {
			long currentTime = System.currentTimeMillis();
			mtTransformation.clear();
			float interpolatedTime = (currentTime - mStartTime) / (float) mDuration;
			getTransformation(v, interpolatedTime);
		}
		return mtTransformation;
	}

	public Transformation getTransformation(FQView v, float interpolatedTime) {
		if (!mIsAnimationEnd) {
			mtTransformation.clear();
			if (interpolatedTime >= 1) {
				interpolatedTime = 1;
				mIsAnimationEnd = true;
			}
			float scaleX = mScaleXFrom + (mScaleXTo - mScaleXFrom) * interpolatedTime;
			float scaleY = mScaleYFrom + (mScaleYTo - mScaleYFrom) * interpolatedTime;
			float degree = mDegreeFrom + (mDegreeTo - mDegreeFrom) * interpolatedTime;
			float offsetX = mOffsetFromX + (mOffsetToX - mOffsetFromX) * interpolatedTime;
			float offsetY = mOffsetFromY + (mOffsetToY - mOffsetFromY) * interpolatedTime;
			Matrix matrix = mtTransformation.getMatrix();
			float anchorX = v.getWidth() * v.mAnchorPoint.x;
			float anchorY = v.getHeight() * v.mAnchorPoint.y;
			matrix.preScale(scaleX, scaleY, anchorX, anchorY);
			matrix.preRotate(degree);
			matrix.preTranslate(offsetX, offsetY);
			mInterpolatedTime = interpolatedTime;
		}
		return mtTransformation;
	}

	public boolean isFinished() {
		return mIsAnimationEnd;
	}

	public void animateEnd() {
		if (mAnimateListener != null) {
			mAnimateListener.onAnimationEnd(Animate.this);
		}
	}
	
	public Animate setScale(float scale){
		mScaleXFrom = mScaleXTo = mScaleYFrom = mScaleYTo = scale;
		return this;
	}
	
	/**
	 * 获取还原动画
	 * @return
	 */
	public Animate recover() {
		float scaleX = mScaleXFrom + (mScaleXTo - mScaleXFrom) * mInterpolatedTime;
		float scaleY = mScaleYFrom + (mScaleYTo - mScaleYFrom) * mInterpolatedTime;
		float degree = mDegreeFrom + (mDegreeTo - mDegreeFrom) * mInterpolatedTime;
		float offsetX = mOffsetFromX + (mOffsetToX - mOffsetFromX) * mInterpolatedTime;
		float offsetY = mOffsetFromY + (mOffsetToY - mOffsetFromY) * mInterpolatedTime;
		Animate animate = new Animate((int) (mDuration * mInterpolatedTime));
		animate.mScaleXFrom = scaleX;
		animate.mScaleXTo = mScaleXFrom;
		animate.mScaleYFrom = scaleY;
		animate.mScaleYTo = mScaleYTo;
		animate.mDegreeFrom = degree;
		animate.mDegreeTo = mDegreeFrom;
 		animate.mOffsetToX = mOffsetFromX;
		animate.mOffsetFromX = offsetX;
		animate.mOffsetFromY = offsetY;
		animate.mOffsetToY = mOffsetFromY;
		return animate;
	}

	public Animate copy() {
		Animate animate = new Animate(mDuration);
		animate.mScaleXFrom = mScaleXFrom;
		animate.mScaleXTo = mScaleXTo;
		animate.mScaleYFrom = mScaleYFrom;
		animate.mScaleYTo = mScaleYTo;
		animate.mDegreeFrom = mDegreeFrom;
		animate.mDegreeTo = mDegreeFrom;
		animate.mOffsetToX = mOffsetToX;
		animate.mOffsetFromX = mOffsetFromX;
		animate.mOffsetFromY = mOffsetFromY;
		animate.mOffsetToY = mOffsetToY;
		return animate;
	}
	
	public void setAnimateListener(AnimateListener l) {
		mAnimateListener = l;
	}
	
	/**
	 * 现在动画状态作为起始状态,把另一个动画的终点状态作为现在动画的终点状态
	 */
	public Animate append(Animate other){
		mScaleXFrom = mScaleXFrom + (mScaleXTo - mScaleXFrom) * mInterpolatedTime;
		mScaleYFrom = mScaleYFrom + (mScaleYTo - mScaleYFrom) * mInterpolatedTime;
		mDegreeFrom = mDegreeFrom + (mDegreeTo - mDegreeFrom) * mInterpolatedTime;
		mOffsetFromX = mOffsetFromX + (mOffsetToX - mOffsetFromX) * mInterpolatedTime;
		mOffsetFromY = mOffsetFromY + (mOffsetToY - mOffsetFromY) * mInterpolatedTime;
		mScaleXTo = other.mScaleXTo;
		mScaleYTo = other.mScaleYTo;
		mDegreeTo = other.mDegreeTo;
		mOffsetToX = other.mOffsetToX;
		mOffsetToY = other.mOffsetToY;
		mDuration = other.mDuration;
		return this;
	}
	
}
