package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import android.view.animation.Transformation;
import android.widget.LinearLayout;
import android.widget.Scroller;

public class FQScrollView extends FQViewGroup {

	private static final float FILING_SCAL = 5f;

	protected Scroller mScroller;

	protected boolean mPressed;

	protected int mOrientation;

	private boolean isDraw = false;

	private int mUScrollX = 0, mUscrollY = 0;

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		invalidate();
		if (mGesture == null) {
			createGesture();
		}
		mGesture.onTouchEvent(event);
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			mPressed = true;
			mScroller.abortAnimation();
			mScroller.startScroll(mScroller.getCurrX(), mScroller.getCurrY(), 0, 0, 0);
		} else if (event.getAction() == MotionEvent.ACTION_UP) {
			this.onKeyUp(event);
			mPressed = false;
			if (mScroller.isFinished()) {
				adjust();
			}
		} else if (event.getAction() == MotionEvent.ACTION_MOVE) {
			if (mGestureListener != null)
				mGestureListener.onMove(event);
		}
		return true;
	}

	@Override
	protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
		mScroller.abortAnimation();
		if(mGestureListener != null && !mGestureListener.canScroll()) return false;
		int max = -getMin();
		int min = -getMax();
		float adsX = Math.abs(distanceX);
		float adsY = Math.abs(distanceY);
		if (mOrientation == LinearLayout.VERTICAL) {
			if (adsX > adsY)
				return true;
			int currentY = mScroller.getCurrY();
			int finalY = mScroller.getFinalY();
			int dis = finalY - currentY;
			int des = currentY + dis - (int) distanceY;
			if (des > max)
				des = max;
			if (des < min)
				des = min;
			mScroller.setFinalY(des);
		} else {
			if (adsX < adsY)
				return true;
			int currentX = mScroller.getCurrX();
			int finalX = mScroller.getFinalX();
			int dis = finalX - currentX;
			int des = currentX + dis - (int) distanceX;
			if (des > max)
				des = max;
			if (des < min)
				des = min;
			mScroller.setFinalX(des);
		}

		return true;
	}

	@Override
	public void draw(Canvas canvas) {
		if (!mScroller.isFinished()) {
			mScroller.computeScrollOffset();
			computeScroll(mScroller.isFinished());
			invalidate();
		}
		super.draw(canvas);
		if (!isDraw) {
			isDraw = true;
			scrollTo(mUScrollX, mUscrollY);
		}
	}

	@Override
	protected void drawBackground(Canvas canvas) {
		if (mOrientation == LinearLayout.VERTICAL) {
			int currentY = -mScroller.getCurrY();
			mTmpRect.set(0, currentY, getWidth(), getHeight() + currentY);
		} else {
			int currentX = -mScroller.getCurrX();
			mTmpRect.set(currentX, 0, getWidth() + currentX, getHeight());
		}
		int color = mBgColor;
		mPaint.setColor(mBgColor);
		canvas.drawRect(mTmpRect, mPaint);
		mPaint.setColor(color);
	}

	public FQScrollView(Context context) {
		super(context);
	}

	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mClipsubviews = false;
		mPressed = false;
		mScroller = new Scroller(context);
		mOrientation = LinearLayout.VERTICAL;
	}

	public void setOrientation(int origentation) {
		mOrientation = origentation;
	}

	public int getOrientation() {
		return mOrientation;
	}

	protected void computeScroll(boolean finished) {
		onComputeScroll();
	}

	protected void adjust() {

	}

	@Override
	protected Transformation getTransformationInfo() {
		mTransformation.clear();
		mTransformation.getMatrix().preTranslate(mFrame.left + mScroller.getCurrX(), mFrame.top + mScroller.getCurrY());
		return mTransformation;
	}

	@Override
	public void onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
		int maxFlingVelocity = ViewConfiguration.getMaximumFlingVelocity();
		if(velocityX > maxFlingVelocity){
			if(velocityX > 0) velocityX = maxFlingVelocity;
			else velocityX = -maxFlingVelocity;
		}
		if(velocityY > maxFlingVelocity){
			if(velocityY > 0) velocityY = maxFlingVelocity;
			else velocityY = -maxFlingVelocity;
		}
		int max = -getMin();
		int min = -getMax();
		if (mOrientation == LinearLayout.VERTICAL) {
			mScroller.fling(mScroller.getCurrX(), mScroller.getCurrY(), 0, (int) (velocityY / FILING_SCAL), 0, 0, min, max);
		} else {
			mScroller.fling(mScroller.getCurrX(), mScroller.getCurrY(), (int) (velocityX / FILING_SCAL ), 0, min, max, 0, 0);
		}
	}

	protected int getMin() {
		return 0;
	}

	protected int getMax() {
		return Integer.MAX_VALUE;
	}

	public void scrollTo(int x, int y) {
		if(x < 0) x = 0;
		if( y < 0) y = 0;
		int max = getMax();
		if(mOrientation == LinearLayout.VERTICAL){
			if(y > max) y = max;
		}else {
			if(x > max) x = max;
		}
		if (!isDraw) {
			mUScrollX += x;
			mUscrollY += y;
		} else {
			mScroller.abortAnimation();
			mScroller.setFinalX(-x);
			mScroller.setFinalY(-y);
			invalidate();
		}
	}
}