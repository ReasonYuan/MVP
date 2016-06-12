package com.fq.library.CustomView.HorScollView;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.HorizontalScrollView;
import android.widget.Toast;

@SuppressLint("ClickableViewAccessibility")
public class CuStomHorizontalScrollView extends HorizontalScrollView{
	private float lastX = 0;
	private float lastY = 0;
	public CuStomHorizontalScrollView(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
	}

	public CuStomHorizontalScrollView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public CuStomHorizontalScrollView(Context context) {
		super(context);
	}

	@Override
	public void scrollTo(int x, int y) {
		super.scrollTo(x, y);
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
			float distanceXY = Math.abs(distanceX)-Math.abs(distanceY);
			int scrollHeight = this.getChildAt(0).getHeight();
			if (distanceXY > 0 && getScrollX() == scrollHeight || distanceXY > 0 && getScrollX() == 0) {
//				getScrollEnd("PAGER_ACTION_MOVE");
				return false;
			}else{
//				getScrollEnd("ACTION_MOVE");
				break;
			}
		default:
			break;
		}
		return super.onTouchEvent(ev);
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
//			if (distanceYX > 10) {
////				getScrollEnd("distanceYX",distanceYX,distanceX,distanceY);
//				return false;
//			}else{
////				System.out.println("~~~~~~~~~~~~~~~~~~~~");
//				return true;
//			}
//		
//		default:
//			break;
//		}
//		
		return super.onInterceptTouchEvent(ev);
	}
	
	
	public void getScrollEnd(String ss){
		int x = this.getScrollX();
		int y = this.getScrollY();
		int height = this.getHeight();
		int scrollHeight = this.getChildAt(0).getHeight();
		int scrollHeight2 = this.getChildAt(0).getMeasuredHeight();
		System.out.println("~~~~~~~~"+ss+"~~~~~~~~"+x+"~~~~~~~~"+y+"~~~~scrollHeight2~~~~"+scrollHeight+"==scrollHeight2=="+scrollHeight2+"====height"+height);
	}
	
	
	public void getScrollEnd(String ss,float distanceYX ){
		System.out.println("~~~~~~~~"+ss+"~~~~~~~~"+distanceYX);
	}
	
	public void getScrollEnd(String ss,float distanceYX ,float distanceX,float distanceY){
		System.out.println("~~~~~~~~"+ss+"~~~~~~~~"+distanceYX+"~~~~~~~~"+distanceX+"~~~~~~~~"+distanceY);
	}
	
	public void getScrollEnd(String ss,MotionEvent ev){
		float x = ev.getX();
		float y = ev.getY();
		System.out.println("~~~~~~~~"+ss+"~~~~~~~~"+x+"~~~~~~~~"+y);
	}
}
