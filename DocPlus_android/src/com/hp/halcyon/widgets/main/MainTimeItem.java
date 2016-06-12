package com.hp.halcyon.widgets.main;


import java.util.ArrayList;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.Typeface;

import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.halcyon.widgets.main.FQStringView.Aligement;

public class MainTimeItem extends FQViewGroup{
	
	private static String MOUNTH[] = {"一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"};
	
	private FQStringView mTitleView;
	
	private ArrayList<Integer> mHaveDataMonth;
	
	private SelectMainTimeView mSelectMainTimeView;
	
	public MainTimeItem(Context context,SelectMainTimeView selectMainTimeView) {
		super(context);
		mSelectMainTimeView = selectMainTimeView;
	}
	
	/**
	 * 重载，动态计算显示年的位置
	 */
	@Override
	protected void onComputeScroll() {
		if(mParent instanceof FQListView){
			FQListView parent = (FQListView) mParent;
			if( mFrame.top < parent.mConmputeRect.top){
				int y =  parent.mConmputeRect.top - mFrame.top;
				if(y > mFrame.height() - mTitleView.mFrame.height()){
					y = mFrame.height() - mTitleView.mFrame.height();
				}
				mTitleView.setPosition(0, y);
			}else {
				mTitleView.setPosition(0, 0);
			}
		}
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mTitleView = new FQStringView(context);
		mTitleView.setTextSize(28);
		mPaint.setStrokeWidth(Tools.dip2px(context,1));
		mTitleView.setTextColor(0xff61c0b4);
		mTitleView.setTypeFace(TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE_BOL));
		this.setClipsubviews(false);
	}
	
	public void setData(String title,ArrayList<Integer> month){
		mTitleView.setText(title);
		mTitleView.setTextAligement(Aligement.RIGHT);
		mHaveDataMonth = month;
		Typeface type = TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE_BOL);
		for (int i = 0; i < 12; i++) {
			FQStringView stringView  = new FQStringView(mContext);
			stringView.setText(MOUNTH[i]);
			stringView.setTypeFace(type);
			//TODO FQStringView只实现Aligement.LEFT
			stringView.setTextAligement(Aligement.LEFT);
			stringView.mDisEnableColor = 0xffDCDDDD;
			addView(stringView);
			
			if(mHaveDataMonth != null && mHaveDataMonth.contains(i+1)){
				final int position = i;
				stringView.setOnClickListener(new FQOnClickListener() {
					@Override
					public void onClick(FQView v) {
						if(mSelectMainTimeView.mListener != null){
							mSelectMainTimeView.mListener.onSelectTime(mTitleView.getText()+"-"+(position+1), "yyyy-MM");
						}
					}

					@Override
					public void onLongPress(FQView v) {
						
					}
				});
			}else {
				stringView.setEnable(false);
			}
		}
		addView(mTitleView);
	}

	
	/**
	 * 这里设置子view的位置
	 */
	@Override
	protected void onFrameChanged() {
		int h = 0;
		int itemHeight = getHeight()/12;
		int margin = getWidth()/6;
		int itemWith = getWidth() - margin;
		for (int i = 0; i < mChild.size(); i++) {
			mChild.get(i).setFrame(margin, h, margin+itemWith, h+itemHeight);
			h += itemHeight;
		}
		mTitleView.setFrame(0, 0, getWidth() - getWidth()/8, Tools.dip2px(mContext, 30));
	}
	
	public void fadeInAnimation(int dur) {
		if(mParent instanceof FQListView){
			FQListView parent = (FQListView) mParent;
			int parrentScroll = -parent.mScroller.getFinalY() ;
			for (int i = 0; i < mChild.size(); i++) {
				FQView child = mChild.get(i);
				Rect absRect = child.getAbsoluteRect();
				absRect.top -= parrentScroll;
				absRect.bottom -= parrentScroll;
				if(absRect.centerY() < parent.mFrame.centerY()){
					Animate animate = new Animate(dur).setOffset(0, 0,-absRect.bottom,0);
					child.startAnimate(animate);
				}else {
					Animate animate = new Animate(dur).setOffset(0, 0,parent.mFrame.bottom - absRect.top,0);
					child.startAnimate(animate);
				}
			}
		}
	}
	
	public void fadeOutAnimation(int dur){
		if(mParent instanceof FQListView){
			FQListView parent = (FQListView) mParent;
			for (int i = 0; i < mChild.size(); i++) {
				FQView child = mChild.get(i);
				Rect absRect = child.getAbsoluteRect();
				Animate animate = null;
				if(absRect.centerY() < parent.mFrame.centerY()){
					animate = new Animate(dur).setOffset(0, 0,0,-absRect.bottom);
					child.startAnimate(animate);
				}else {
					animate = new Animate(dur).setOffset(0, 0,0,parent.mFrame.bottom - absRect.top);
					child.startAnimate(animate);
				}
			}
		}
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		mPaint.setColor(0xffb0b0b0);
		canvas.drawLine(0, 0, mFrame.width(),0, mPaint);
		super.onDraw(canvas);
	}

}
