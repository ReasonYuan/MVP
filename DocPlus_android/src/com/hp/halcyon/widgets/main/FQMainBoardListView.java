package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;

import com.hp.android.halcyon.widgets.DailyRecViewLogic;

public class FQMainBoardListView extends FQListView {
	
	private int[] mDailyRecNums;
	
	
	private DailyRecViewLogic mDailyRecViewLogic;
	
	public FQMainBoardListView(Context context, int bottomLineHeight) {
		super(context);
		//TODO 
//		mDailyRecViewLogic = new DailyRecViewLogic(this, bottomLineHeight);
	}
	
	@Override
	public void setAdapter(FQBaseViewAdapter adapter) {
		super.setAdapter(adapter);
		updateDailyRecViewData();
	}
	
	@Override
	public void onDataSetChanged() {
		super.onDataSetChanged();
		updateDailyRecViewData();
	}

	private void updateDailyRecViewData(){
//		mDailyRecNums = new int[mAdapter.getCount()];
//		Random r = new Random(System.currentTimeMillis());
//		for (int i = 0; i < mDailyRecNums.length; i++) {
//			mDailyRecNums[i] = r.nextInt(600);
//		}
		mDailyRecNums = ((MainView2.FQMainBoardListAdapter)mAdapter).getDatas();
		if (mDailyRecNums == null) {
			mDailyRecNums = new int[0];
		}
		mDailyRecViewLogic.setDailyRecData(mDailyRecNums);
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
	}
	
	@Override
	protected void computeScroll(boolean finished) {
		super.computeScroll(finished);
		if(mDailyRecViewLogic.isDataReady() && mChild.size() > 0){
			mDailyRecViewLogic.scrollTo(mFirstView.mPosition, mLastView.mPosition, mFirstView.mFrame.width(), mFirstView.mFrame.centerX() - (-mScroller.getCurrX()));
		}
	}

	@Override
	protected void beforeDraw(Canvas canvas) {
		if(mChild.size() > 0 && mDailyRecViewLogic.isDataReady()){
			mDailyRecViewLogic.showDailyRecLines(canvas);
		}
		super.beforeDraw(canvas);
	}
	
	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
	}

}
