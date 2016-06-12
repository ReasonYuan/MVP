package com.fq.android.plus.guidepage;

import android.content.Context;
import android.view.animation.Interpolator;
import android.widget.Scroller;

public class MyScroller extends Scroller {
	 private int mDuration = 1500;
	 
	    public MyScroller(Context context) {
	        super(context);
	    }
	 
	    public MyScroller(Context context, Interpolator interpolator) {
	        super(context, interpolator);
	    }
	 
	    @Override
	    public void startScroll(int startX, int startY, int dx, int dy, int duration) {
	        super.startScroll(startX, startY, dx, dy, mDuration);
	    }
	 
	    @Override
	    public void startScroll(int startX, int startY, int dx, int dy) {
	        super.startScroll(startX, startY, dx, dy, mDuration);
	    }
	 
	    public void setmDuration(int time) {
	        mDuration = time;
	    }
	 
	    public int getmDuration() {
	        return mDuration;
	    }
	}