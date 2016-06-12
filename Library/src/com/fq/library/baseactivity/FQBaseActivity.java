package com.fq.library.baseactivity;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;

import com.fq.android.library.R;
import com.fq.library.topbar.FQTopbar;
import com.fq.library.topbar.FQTopbar.OnTopbarClickListener;

public abstract class FQBaseActivity extends Activity{

	protected FrameLayout mContainer;
	protected FQTopbar mTopbar;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_fq_base);
		mTopbar= (FQTopbar) findViewById(R.id.fqt_base_bar);
		mContainer = (FrameLayout) findViewById(R.id.fl_parent_container);
		int id = getContentId();
		if(id != 0){
			mContainer.addView(LayoutInflater.from(this).inflate(id, null));
		}
		mTopbar.setTopbarClickListener(new OnTopbarClickListener() {
			
			@Override
			public void onRightClick() {
				onTopRightBtnClick();
			}
			
			@Override
			public void onLeftClick() {
				onTopLeftBtnClick();
			}
		});
		init();
		setActivityStyle();
	}
	
	public abstract int getContentId();
	
	public abstract void init();
	
	public abstract void setActivityStyle();
	
	/**
	 * 获取某个view，代替繁琐的findViewById
	 * @param id
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public final <E extends View> E getView (int id) {
	    try {
	        return (E) findViewById(id);
	    } catch (ClassCastException ex) {
	        throw ex;
	    }
	}
	
	public void setBackground(int resid){
		mContainer.setBackgroundResource(resid);
	}
	
	public void setBackground(Drawable background){
		mContainer.setBackground(background);
	}
	
	public void setBackgroundColor(int color){
		mContainer.setBackgroundColor(color);
	}
	
	public void setLeftBtnShow(boolean isShow){
		mTopbar.mLeftBtn.setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setLeftBtnText(String text){
		mTopbar.mLeftBtn.setText(text);
	}
	
	public void setLeftBtnText(int resid){
		mTopbar.mLeftBtn.setText(resid);
	}
	
	public void setLeftBtnTextColor(int color){
		mTopbar.mLeftBtn.setTextColor(color);
	}
	
	public void setLeftBtnBackground(int resid){
		mTopbar.mLeftBtn.setBackgroundResource(resid);
	}
	
	public void setRightBtnShow(boolean isShow){
		mTopbar.mRightBtn.setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setRightBtnText(String text){
		mTopbar.mRightBtn.setText(text);
	}
	
	public void setRightBtnText(int resid){
		mTopbar.mRightBtn.setText(resid);
	}
	
	public void setRightBtnTextColor(int color){
		mTopbar.mRightBtn.setTextColor(color);
	}
	
	public void setRightBtnBackground(int resid){
		mTopbar.mRightBtn.setBackgroundResource(resid);
	}
	
	public void setTitleText(String text){
		mTopbar.mTitle.setText(text);
	}
	
	public void setTitleText(int resid){
		mTopbar.mTitle.setText(resid);
	}
	
	public void setTitleTextColor(int color){
		mTopbar.mTitle.setTextColor(color);
	}
	
	public void onTopLeftBtnClick(){
		onBackPressed();
	}
	
	public void onTopRightBtnClick(){
	}
}
