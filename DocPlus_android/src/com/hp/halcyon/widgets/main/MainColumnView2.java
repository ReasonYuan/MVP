package com.hp.halcyon.widgets.main;


import java.util.LinkedList;
import java.util.Queue;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;

import com.fq.lib.callback.ICallback;

public class MainColumnView2 extends FQViewGroup {

	FQView mHeaderView;
	
	FQView mTView;
	
	FQView mMoreView;
	
	Queue<FQView> mQueue;
	
	private int mHeightMargin = 0;
	
	private boolean mHaveTView,mHaveMoreView;
	
	public MainColumnView2(Context context) {
		super(context);
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mQueue = new LinkedList<FQView>();
	}
	
	public void setTView(FQView tView){
		mTView = tView;
		mTView.mParent = null;
		addView(mTView);
		mHaveTView = true;
	}
	
	public void setMoreView(FQView moreView){
		mMoreView = moreView;
		mMoreView.mParent = null;
		addView(mMoreView);
		mHaveMoreView = true;
	}
	
	public void setHeaderView(FQView header){
		mHeaderView = header;
		mHeaderView.mParent = null;
		addView(mHeaderView);
	}

	@Override
	protected void onFrameChanged() {
		int headerheigth = getHeight()/7;
		int leftHeigth = getHeight() - headerheigth;
		int sumMargin = leftHeigth/15;
		mHeightMargin = sumMargin/7;
		int itemHeigth = (leftHeigth-sumMargin)/7;
		int y = mFrame.bottom - headerheigth;
		mHeaderView.setFrame(0, y, getWidth(), mFrame.bottom);
		int squareWidth = Math.min(getWidth(), itemHeigth);
		int marginLeft = (getWidth() -squareWidth)/2;
		int marginTop = (itemHeigth -squareWidth)/2;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			if(child == mHeaderView || child == mTView || child == mMoreView) continue;
			y -= itemHeigth;
			y -= mHeightMargin;
			mChild.get(i).setFrame(0 + marginLeft, y + marginTop, marginLeft + squareWidth, y + marginTop + squareWidth);
		}
		if(mMoreView != null && mHaveMoreView){
			y -= itemHeigth;
			y -= mHeightMargin;
			mMoreView.setFrame(0 + marginLeft, y + marginTop, marginLeft + squareWidth, y + marginTop + squareWidth);
		}
		if(mTView != null && mHaveTView){
			y -= itemHeigth;
			y -= mHeightMargin;
			mTView.setFrame(0 + marginLeft, y + marginTop, marginLeft + squareWidth, y + marginTop + squareWidth);
		}
	}

	public void reset(ICallback callback) {
		cleanAnimae();
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			if(child != mHeaderView && child != mTView && child != mMoreView){
				child.mParent = null;
				mQueue.add(child);
				callback.doCallback(child);
			}
		}
		mHaveTView = mHaveMoreView = false;
		mChild.clear();
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
	}
	
}
