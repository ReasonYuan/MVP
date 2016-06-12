package com.hp.android.halcyon.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.FrameLayout;

public class InterceptTouchView extends FrameLayout {
	
	public InterceptTouchView(Context context) {
		super(context);
	}

	public InterceptTouchView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public InterceptTouchView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
	}
	

	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		return true;
	}
	
}
