package com.hp.halcyon.widgets.home;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.widget.LinearLayout;

import com.hp.android.halcyon.HomeActivity.MyOnGestureListener;

@SuppressLint("NewApi")
public class HomeViewLayout extends LinearLayout {

	private GestureDetector mGestureDetector;

	public  MyOnGestureListener mGestureListener;
	
	public HomeViewLayout(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public HomeViewLayout(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	public HomeViewLayout(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	
	public void setGestureListener(GestureDetector gestureDetector,MyOnGestureListener gestureListener){
		mGestureDetector = gestureDetector;
		mGestureListener = gestureListener;
	}
	
	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		if(mGestureDetector != null){
			mGestureDetector.onTouchEvent(ev);
			if (ev.getAction() == MotionEvent.ACTION_MOVE) {
				mGestureListener.onMove(ev);
			}
			if (ev.getAction() == MotionEvent.ACTION_UP) {
				mGestureListener.onUp(ev);
			}
		}
		return super.dispatchTouchEvent(ev);
	}
}
