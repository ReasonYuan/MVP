package com.hp.android.halcyon.view;

import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;

import com.fq.android.plus.R;
import com.hp.android.halcyon.HomeActivity;
import com.hp.android.halcyon.SnapPicActivity;

public class AddTimerRecordView implements OnClickListener{

	private Context mContext;
	private View mView;
	
	
	public AddTimerRecordView(Context context){
		mContext = context;
		mView = LayoutInflater.from(context).inflate(R.layout.activity_add_remind_record, null);
		mView.findViewById(R.id.btn_add_close).setOnClickListener(this);
		mView.findViewById(R.id.btn_add_timer).setOnClickListener(this);
		mView.findViewById(R.id.btn_add_record).setOnClickListener(this);
		
		mView.setOnKeyListener(new OnKeyListener() {
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if(keyCode == KeyEvent.KEYCODE_BACK){
					dismiss();
					return true;
				}
				return false;
			}
		});
	}

	public View getView(){
		return mView;
	}

	public boolean isShow(){
		return mView.isShown();
	}
	
	public void show(ViewGroup parent){
		((HomeActivity)mContext).blur();
		parent.addView(mView);
		AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
		alphaAnimation.setDuration(800);
		mView.startAnimation(alphaAnimation);
	}
	
	public void dismiss(){
		try {
			((HomeActivity)mContext).unblur();
			AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0);
			alphaAnimation.setDuration(800);
			mView.startAnimation(alphaAnimation);
			((ViewGroup)mView.getParent()).removeView(mView);
		} catch (Exception e) {
			// TODO: handle exception
		}
		
	}
	
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_add_close:
			break;
		case R.id.btn_add_timer:
			newTimer();
			break;
		case R.id.btn_add_record:
			newRecord();
			break;
		}
		dismiss();
	}
	
	public void newRecord(){
		mContext.startActivity(new Intent(mContext, SnapPicActivity.class));
//		mContext.startActivity(new Intent(mContext, UploadStateActivity.class));
	}
	public void newTimer(){
//		mContext.startActivity(new Intent(mContext, SetRemindActivity.class));
	}
}
