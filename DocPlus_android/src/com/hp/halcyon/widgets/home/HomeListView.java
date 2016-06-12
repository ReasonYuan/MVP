package com.hp.halcyon.widgets.home;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.hp.android.halcyon.widgets.DailyRecViewLogic;
import com.hp.halcyon.widgets.main.MainView2;
import com.hp.halcyon.widgets.main.Tools;

public class HomeListView extends HorizontalListView {

	public static HomeListView mInstance;

	private int[] mDailyRecNums;
	
	private DailyRecViewLogic mDailyRecViewLogic;
	
	private Rect mRect;

	public interface OnScrollListener {
		public void onScroll(HorizontalListView view, int scrollX);
	}

	private OnScrollListener mScrollListener;
	public float mTouchDownY;

	public HomeListView(Context context) {
		super(context, null);
		mInstance = this;
		mRect = new Rect();
		mDailyRecViewLogic = new DailyRecViewLogic(this,Tools.px2dip(getContext(), getItemWith()));
	}
	
	@Override
	protected void onDataSetChange() {
		updateDailyRecViewData();
	}
	
	private void updateDailyRecViewData(){
		mDailyRecNums =((HomeListViewAdapter)mAdapter).getMainBoardList();
		if (mDailyRecNums == null) {
			mDailyRecNums = new int[0];
		}
		mDailyRecViewLogic.setDailyRecData(mDailyRecNums);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		mTouchDownY = event.getY();
		return super.onTouchEvent(event);
	}

	public HomeListView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mInstance = this;
	}

	public HomeListView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs);
		mInstance = this;
	}

	@Override
	protected void recycleView(int adapterIndex, View view) {
		super.recycleView(adapterIndex, view);
		if (mAdapter instanceof HomeListViewAdapter) {
			((HomeListViewAdapter) mAdapter).onRecycleItemView(adapterIndex, view);
		}
	}

	public static int getItemWith() {
		if(mInstance != null) return mInstance.getMeasuredHeight() / 7;
		return 0;
	}

	@Override
	public void scrollTo(final int x, final boolean animation) {
		postDelayed(new Runnable() {
			
			@Override
			public void run() {
				HomeListView.super.scrollTo(x, animation);				
			}
		}, 0);
		HomeListView.super.scrollTo(x, animation);
	}

	

	@Override
	protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
		super.onLayout(changed, left, top, right, bottom);
		mDailyRecViewLogic.setBottomLineHeight(Tools.px2dip(getContext(), getItemWith()) + MainView2.MARGINT);
		if (mScrollListener != null) {
			mScrollListener.onScroll(this, mNextX < 0 ? 0 : mNextX);
		}
	}

	public void setOnScrollListener(OnScrollListener l) {
		mScrollListener = l;
	}

	@Override
	public void computeScroll() {
		super.computeScroll();
		int itemWidth = getItemWith();
		if(getChildCount()>  0 && mDailyRecViewLogic!= null && mDailyRecViewLogic.isDataReady()){
			getChildAt(0).getHitRect(mRect);
			int lastPosition = getLastVisiblePosition();
			if(lastPosition < mAdapter.getCount() - 1) lastPosition += 1;
			mDailyRecViewLogic.scrollTo(getFirstVisiblePosition(),lastPosition, itemWidth, mRect.centerX());
		}
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if(mDailyRecViewLogic.isDataReady()){
			mDailyRecViewLogic.showDailyRecLines(canvas);
		}
	}
}
