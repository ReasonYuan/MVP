package com.fq.library.CustomView.HorScollView;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ListView;

@SuppressLint("ClickableViewAccessibility")
public class CustomListView extends ListView{
	private float lastX = 0;
	private float lastY = 0;
	public CustomListView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public CustomListView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public CustomListView(Context context) {
		super(context);
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
//		float newX = 0;
//		float newY = 0;
//		newX = ev.getX();
//		newY = ev.getY();
//		switch (ev.getAction()) {
//		case MotionEvent.ACTION_DOWN:
//			lastX = newX;
//			lastY = newY;
//			break;
//		case MotionEvent.ACTION_MOVE:
//			break;
//		case MotionEvent.ACTION_UP:
//			float distanceY = newY - lastY;
//			float distanceX = newX - lastX;
//			float distanceYX = Math.abs(distanceY)-Math.abs(distanceX);
//			if (distanceYX > 50) {
////				getScrollEnd("ListView_____distanceYX",distanceYX);
//				return true;
//			}else{
//				return false;
//			}
//		default:
//			break;
//		}
		return super.onInterceptTouchEvent(ev);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		float newX = 0;
		float newY = 0;
		newX = ev.getX();
		newY = ev.getY();
		switch (ev.getAction()) {
		case MotionEvent.ACTION_DOWN:
			lastX = newX;
			lastY = newY;
			break;
		case MotionEvent.ACTION_MOVE:
			break;
		case MotionEvent.ACTION_UP:
			float distanceY = newY - lastY;
			float distanceX = newX - lastX;
			float distanceYX = Math.abs(distanceY)-Math.abs(distanceX);
			if (distanceYX > 10) {
//				getScrollEnd("distanceYX",distanceYX,distanceX,distanceY);
				break;
			}else{
//				System.out.println("~~~~~~~~~~~~~~~~~~~~");
				return false;
			}
		
		default:
			break;
		}
		
		return super.onTouchEvent(ev);
	}
	

	public void getScrollEnd(String ss,float distanceYX ){
		System.out.println("~~~~~~~~"+ss+"~~~~~~~~"+distanceYX);
	}
}
