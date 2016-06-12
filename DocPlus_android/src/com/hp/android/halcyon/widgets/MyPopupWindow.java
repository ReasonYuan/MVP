package com.hp.android.halcyon.widgets;

import android.app.ActionBar.LayoutParams;
import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.PopupWindow;

import com.fq.android.plus.R;

public class MyPopupWindow extends PopupWindow{

	private View mView;
	
	public MyPopupWindow(Activity context, int layout) {
		LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mView = inflater.inflate(layout, null);
		//设置PopupWindow的View   
		this.setContentView(mView);  
		setWindow();
		
		mView.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View view, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_UP){
						//dismiss();
				}
				return true;
			}
		});
	}
	
	public View getView() {
		return mView;
	}

	/**
	 * 调用此方法设置弹出窗口的宽、高和动画属性
	 * @param width 宽
	 * @param height 高
	 * @param animationStyle 动画属性
	 * */
	public void setWindow(int width, int height, int animationStyle){
		//设置PopupWindow弹出窗体的宽   
		this.setWidth(width);   
		//设置PopupWindow弹出窗体的高   
		this.setHeight(height);   
		//设置PopupWindow弹出窗体可点击   
		this.setFocusable(true);   
		//设置PopupWindow弹出窗体动画效果   
		this.setAnimationStyle(animationStyle);
		//设置PopupWindow弹出窗体背景
		this.setBackgroundDrawable(new ColorDrawable());
		
	}

	/**
	 * 默认弹出窗口设置
	 * */
	private void setWindow(){
		//设置PopupWindow弹出窗体的宽   
		this.setWidth(LayoutParams.WRAP_CONTENT);   
		//设置PopupWindow弹出窗体的高   
		this.setHeight(LayoutParams.WRAP_CONTENT);   
		//设置PopupWindow弹出窗体可点击   
		this.setFocusable(true);   
		//设置PopupWindow弹出窗体动画效果   
		this.setAnimationStyle(R.style.popupAnimation);
		//设置PopupWindow弹出窗体背景
		this.setBackgroundDrawable(new ColorDrawable());
		
	}
	

}
