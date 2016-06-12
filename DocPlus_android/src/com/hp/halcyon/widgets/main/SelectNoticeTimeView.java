package com.hp.halcyon.widgets.main;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.GradientDrawable.Orientation;
import android.util.AttributeSet;
import android.view.MotionEvent;

import com.hp.halcyon.widgets.main.DateViewGroup.OnChangeListener;

public class SelectNoticeTimeView extends FQBaseView implements OnChangeListener{

	private static final int[] SHADOWS_COLORS = new int[] { 0x00FaFaFa, 0x96FaFaFa, 0xFFFaFaFa };

	private static int ITEM_HEIGHT;

	private GradientDrawable mShadow;

	private DateViewGroup mDate, mHour, mMinute;
	
	private OnChangeListener mChangeListener;

	public SelectNoticeTimeView(Context context) {
		super(context);
	}

	public SelectNoticeTimeView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public SelectNoticeTimeView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
	}

	public Date getSelectDate(){
		SimpleDateFormat mDateFormat = new SimpleDateFormat("yyyy-MM-dd HH mm");
		String dateString = mDate.getCurrnet() + " "+ mHour.getCurrnet() + " "+ mMinute.getCurrnet();
		try {
			return mDateFormat.parse(dateString);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return new Date();
	}
	
	@Override
	protected void init(Context context) {
		super.init(context);
		ITEM_HEIGHT = Tools.dip2px(context,30);
		mShadow = new GradientDrawable(Orientation.TOP_BOTTOM, SHADOWS_COLORS);
		int type = 1;
		mDate = new DateViewGroup(context, ITEM_HEIGHT, type++);
		mHour = new DateViewGroup(context, ITEM_HEIGHT, type++);
		mMinute = new DateViewGroup(context, ITEM_HEIGHT, type++);
		mViewGroup.addView(mDate);
		mViewGroup.addView(mHour);
		mViewGroup.addView(mMinute);
		mDate.setOnChangeListener(this);
		mHour.setOnChangeListener(this);
		mMinute.setOnChangeListener(this);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int measureWidth = getMeasuredWidth();
		int measureHeight = getMeasuredHeight();
		int startX = measureWidth/15;
		int width = measureWidth * 3 / 8;
		mDate.setFrame(startX, 0, startX+ width, measureHeight);
		startX += width ;
		width = measureWidth / 6;
		mHour.setFrame(startX, 0, startX + width, measureHeight);
		startX += width ;
		mMinute.setFrame(startX, 0, startX + width, measureHeight);
	}

	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
		mShadow.setBounds(0, 0, mViewGroup.mFrame.width(), mViewGroup.mFrame.height());
		mShadow.draw(canvas);
	}

	/**
	 * 当前正在处理事件的view
	 */
	private FQViewGroup mHandleView;

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			for (int i = 0; i < mViewGroup.mChild.size(); i++) {
				FQView child = mViewGroup.mChild.get(i);
				if (child.mFrame.contains((int) event.getX(), (int) event.getY())) {
					mHandleView = (FQViewGroup) child;
				}
			}
		}
		if (mHandleView != null) {
			mHandleView.dispatchTouchEvent(event);
		}
		if (event.getAction() == MotionEvent.ACTION_UP)
			mHandleView = null;
		return true;
	}

	@Override
	public void onDateChanged() {
		if(mChangeListener !=null) mChangeListener.onDateChanged();
	}
	
	public void setOnChangeListener(OnChangeListener l){
		mChangeListener = l;
	}
}
