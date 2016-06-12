package com.hp.android.halcyon.view;

import java.util.Random;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.ScaleAnimation;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.TextFontUtils;

public class UserActionItemView extends FrameLayout {
	private View mView;
	
	private TextView mDateText;
	private TextView mTitleText;
	private TextView mDesText;
	
	private int SPEED_X;
	private int SPEED_Y;
	private Random mRandom;
	private Rect mRect;
	private boolean mIsFrist = true;
	
	public UserActionItemView(Context context){
		super(context);
		mView = LayoutInflater.from(context).inflate(R.layout.item_doctor_distory, null);
		mDateText = (TextView) mView.findViewById(R.id.tv_history_date);
		mTitleText = (TextView) mView.findViewById(R.id.tv_history_title);
		mDesText = (TextView) mView.findViewById(R.id.tv_history_des);
		setFont();
		 setAlpha();
		addView(mView);
		setBackgroundColor(Color.TRANSPARENT);
		
	}
	
	/*public View getView(){
		return mView;
	}*/
	
//	public void init(){
//		mView = LayoutInflater.from(getContext()).inflate(R.layout.item_doctor_distory, null);
//		mDateText = (TextView) mView.findViewById(R.id.tv_history_date);
//		mTitleText = (TextView) mView.findViewById(R.id.tv_history_title);
//		mDesText = (TextView) mView.findViewById(R.id.tv_history_des);
//	}
	
	public void setScale(float scale){
		mView.setScaleX(scale);
		mView.setScaleY(scale);
	}
	
	public void setAlpha(){
		Random mRandom = new Random();
		mDateText.setAlpha((float)(mRandom.nextInt(9)*0.1+0.1));
		mTitleText.setAlpha((float)(mRandom.nextInt(9)*0.1+0.1));
		mDesText.setAlpha((float)(mRandom.nextInt(9)*0.1+0.1));
	}
	
	public void setGravity(int gravity){
		mDateText.setGravity(gravity);
		mTitleText.setGravity(gravity);
		mDesText.setGravity(gravity);
	}
	
	public void setFont(){
//		Typeface mFont = Typeface.createFromAsset(getResources().getAssets(),
//				"ElleNovCMed.otf");
		Typeface mFont = TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE);
		mDateText.setTypeface(mFont);
		mTitleText.setTypeface(mFont);
		mDesText.setTypeface(mFont);
	}
	
	public void setInfo(String date,String title,String des){
		mDateText.setText(date);
		mTitleText.setText(title);
		mDesText.setText(des);
	}
	
	public void setTextSize(float date,float title,float des){
		mDateText.setTextSize(date);
		mTitleText.setTextSize(title);
		mDesText.setTextSize(des);
//		mDateText.setTextSize(UITools.sp2px(mContext, date));
//		mTitleText.setTextSize(UITools.sp2px(mContext, title));
//		mDesText.setTextSize(UITools.sp2px(mContext, des));
	}
	
	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		
		ScaleAnimation scale = new ScaleAnimation(0, 1, 0, 1,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
		scale.setDuration(1000);
		scale.setFillAfter(true);
		startAnimation(scale);
		
		mRandom = new Random();
		SPEED_X = mRandom.nextBoolean()?1:-1;//2 - mRandom.nextInt(5);
		SPEED_Y = mRandom.nextBoolean()?1:-1;
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if(mIsFrist){
			mIsFrist = false;
			mRect = new Rect(getLeft(), getTop(), getRight(), getBottom());
		}
		
		int l = getLeft()+SPEED_X;//3-mRandom.nextInt(7);
		int t = getTop()+SPEED_Y;//3-mRandom.nextInt(7);
		
		if(l < mRect.left-20 || l > mRect.left+20){
			SPEED_X = 0 - SPEED_X;
		}
		
		if(t < mRect.top-20 || t > mRect.top+20){
			SPEED_Y = 0 - SPEED_Y;
		}
		
		layout(l, t, l+getWidth(), t+getHeight());
		
		postInvalidateDelayed(100);
	}
}
