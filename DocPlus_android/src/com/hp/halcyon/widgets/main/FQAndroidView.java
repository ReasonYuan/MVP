package com.hp.halcyon.widgets.main;

import java.lang.reflect.Field;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.os.Build.VERSION;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.MeasureSpec;

public class FQAndroidView extends FQView {
	
	protected View mView;

	public FQAndroidView(Context context) {
		super(context);
	}

	public FQAndroidView(Context context, Rect frame) {
		super(context, frame);
	}

	public FQAndroidView(Context context, int left, int top, int right, int bottom) {
		super(context, left, top, right, bottom);
	}

	@Override
	protected void onFrameChanged() {
		super.onFrameChanged();
		mView.measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.AT_MOST),  
                MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.AT_MOST));
		mView.layout(mFrame.left, mFrame.top, mFrame.right, mFrame.bottom);
	}
	
	public void setView(View view){
		mView = view;
		mView.measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.AT_MOST),  
                MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.AT_MOST));
		mView.layout(mFrame.left, mFrame.top, mFrame.right, mFrame.bottom);
	}
	
	public View getView(){
		return mView;
	}
	
	
	@Override
	protected boolean canHandleSingleTapUp() {
		if(super.canHandleSingleTapUp()) return true;
		if(mView == null) return false;
		if (VERSION.SDK_INT >= 15) {//VERSION_CODES.ICE_CREAM_SANDWICH_MR1 = 15
			return checkOnClick15();
		}else {
			return CheckOnClick();
		}
	}
	
	@TargetApi(15)
	private boolean checkOnClick15(){
		return mView != null && mView.hasOnClickListeners();
	}
	
	private boolean CheckOnClick(){
		Field[] declaredFields = View.class.getDeclaredFields(); 
		for (int i = 0; i < declaredFields.length; i++) {
			if(declaredFields[i].getName().equals("mOnClickListener")){
				try {
					declaredFields[i].setAccessible(true);
					boolean onClick = declaredFields[i].get(mView) != null;
					declaredFields[i].setAccessible(false);
					return onClick;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}
	
	
	@Override
	protected boolean onSingleTapUp(MotionEvent e) {
		super.onSingleTapUp(e);
		return mView.performClick();
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		if(mView != null) mView.draw(canvas);
	}
	
	public View findViewById(int id){
		return mView.findViewById(id);
	}
}
