package com.hp.halcyon.widgets.main;


import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.View;

public class MainColumnView extends FQViewGroup {

	private int mCurrentBottomPosition = 0;

	/**
	 * use default width 60dp <br/>
	 * 由于最下的header需要连接成一条直线，所以现在改为70<br/>
	 * item仍然是60，多出来的10作为padding
	 */
	public MainColumnView(Context context) {
		super(context);
	}
	
	public MainColumnView(Context context, int width) {
		super(context, 0, 0, width, 0);
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		if(mFrame.isEmpty()){
			mFrame.set(0,0,Tools.dip2px(context, 70),0);
		}
		mCurrentBottomPosition = mFrame.bottom - mFrame.top;
	}
	
	@Override
	protected void onFrameChanged() {
		super.onFrameChanged();
		mCurrentBottomPosition = mFrame.bottom - mFrame.top;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			Rect frame = child.mFrame;
			int frameHeight = frame.bottom - frame.top;
			child.setFrame(0, mCurrentBottomPosition - frameHeight, getWidth(), mCurrentBottomPosition);
			frameHeight = frame.bottom - frame.top;
			mCurrentBottomPosition -= frameHeight + Tools.dip2px(mContext, 10);
		}
	}
	
	protected boolean onSingleTapUp(MotionEvent e) {
		if (mOnClickListener != null) {
			mOnClickListener.onClick(this);
		}
		return false;
	}

	
	@Override
	public FQView addView(View view) {
		FQView child = super.addView(view);
		if(child != null){
			Rect frame = child.mFrame;
			int frameHeight = frame.bottom - frame.top;
			child.setFrame(0, mCurrentBottomPosition - frameHeight, getWidth(), mCurrentBottomPosition);
			frameHeight = frame.bottom - frame.top;
			mCurrentBottomPosition -= frameHeight;// + Tools.dip2px(mContext, 10);
		}
		return child;
	}
	
	public FQView addView(View view,int padding) {
		FQView child = super.addView(view);
		if(child != null){
			Rect frame = child.mFrame;
			int frameHeight = frame.bottom - frame.top;
			child.setFrame(0, mCurrentBottomPosition - frameHeight, getWidth(), mCurrentBottomPosition);
			frameHeight = frame.bottom - frame.top;
			mCurrentBottomPosition -= frameHeight + Tools.dip2px(mContext,padding);
		}
		return child;
	}
	
	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
	}
	
}
