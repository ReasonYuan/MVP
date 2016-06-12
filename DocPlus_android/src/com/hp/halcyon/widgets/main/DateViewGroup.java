package com.hp.halcyon.widgets.main;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import android.content.Context;

import com.hp.android.halcyon.util.TextFontUtils;

public class DateViewGroup extends FQListView {

	public static interface OnChangeListener {
		public void onDateChanged();
	}

	private static final float SCALE = 1.2f;

	private OnChangeListener mChangeListener;
	private int mItemHeight;
	private int mType;
	private SimpleDateFormat mDateFormat;


	/**
	 * 
	 * @param context
	 * @param itemHeight
	 * @param type
	 *            1年月 2小时 3 分钟
	 */
	public DateViewGroup(Context context, int itemHeight, int type) {
		super(context);
		mType = type;
		mItemHeight  = itemHeight;
		switch (mType) {
		case 1:
			mDateFormat = new SimpleDateFormat("yyyy-MM-dd ");
			break;
		case 2:
			mDateFormat = new SimpleDateFormat("HH");
			break;
		case 3:
		default:
			mDateFormat = new SimpleDateFormat("mm");
			break;
		}
		setAdapter(new FQBaseViewAdapter() {
			
			@Override
			public FQView getView(final int position, FQView convertView, int parentWidth, int parentHeight) {
				if(convertView == null){
					convertView = new FQStringView(mContext);
					((FQStringView)convertView).setTypeFace(TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE));
				}
				convertView.setFrame(0, 0, parentWidth, mItemHeight);
				((FQStringView)convertView).setText(getIndex(position));
				return convertView;
			}
			
			@Override
			public int getCount() {
				return Integer.MAX_VALUE;
			}
		});
	}

	public String getCurrnet() {
		return getIndex(mFirstView.mPosition);
	}

	private String getIndex(int index) {
		Date tmpDate;
		Calendar calendar = Calendar.getInstance();
		switch (mType) {
		case 1:
			calendar.add(Calendar.DAY_OF_YEAR, index);
			tmpDate = calendar.getTime();
			break;
		case 2:
			calendar.add(Calendar.HOUR, index);
			tmpDate = calendar.getTime();
			break;
		case 3:
		default:
			calendar.add(Calendar.MINUTE, index);
			tmpDate = calendar.getTime();
			break;
		}
		return mDateFormat.format(tmpDate);
	}

	@Override
	protected void onFrameChanged() {
		if (mFrame.width() == 0 || mFrame.height() == 0)
			return;
		super.onFrameChanged();
		mConmputeRect.set(0,0,getWidth(),getHeight());
		if (!mChild.isEmpty()) {
			FQStringView child = (FQStringView) mChild.get(0);
			Animate animate = child.getAnimate();
			animate.setScale(SCALE);
			animate.setOffset(0, 0);
			child.startAnimate(animate);
		}
	}
	
	
	@Override
	public FQView addView(FQView view) {
		view.setAnchor(0.5f, 0.5f);
		Animate animate = view.getAnimate();
		if (animate == null) {
			animate = new Animate(0);
		}
		animate.setScale(1.f);
		animate.setOffset(0, mItemHeight * (SCALE - 1));
		view.startAnimate(animate);
		return super.addView(view);
	}

	@Override
	protected void adjust() {
		int currnetScrollY = -mScroller.getCurrY();
		mConmputeRect.set(0, currnetScrollY, getWidth(), currnetScrollY + getHeight());
		if (mConmputeRect.top != mFirstView.mFrame.top) {
			mScroller.startScroll(0, mScroller.getCurrY(), 0, mConmputeRect.top - mFirstView.mFrame.top, 200);
		}
	}

	@Override
	protected void onComputeScroll() {
		float offsetY = mItemHeight * (SCALE - 1);
		int scrollY = -mScroller.getCurrY();
		float halfHeight = mItemHeight / 2.f;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			Animate animate = child.getAnimate();
			animate.mIsAnimationEnd = false;
			if (child.mFrame.contains(0, scrollY)) {
				float dis = Math.abs(scrollY - child.mFrame.centerY());
				float scale = 1 + (SCALE - 1) * dis / halfHeight;
				animate.setScale(scale);
				animate.setOffset(0, offsetY * (SCALE - scale));
			} else {
				animate.setOffset(0, offsetY).setScale(1.f);
			}
		}
		int currnetScrollY = -mScroller.getCurrY();
		mConmputeRect.set(0, currnetScrollY, getWidth(), currnetScrollY + getHeight());
		if (mChangeListener != null  && mConmputeRect.top == mFirstView.mFrame.top) {
			mChangeListener.onDateChanged();
		}
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			Animate animate = child.getAnimate();
			animate.mIsAnimationEnd = false;
		}
	}

	public void setOnChangeListener(OnChangeListener l) {
		mChangeListener = l;
	}
	
	@Override
	protected int getMax() {
		return Integer.MAX_VALUE;
	}
	
	@Override
	protected int getMin() {
		return -2000000;
	}

	@Override
	protected void resetChild() {
		int height = 0;
		boolean isFinished = false;
		int index = 0;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			mRemoveQueue.add(child);
			child.mParent = null;
		}
		mChild.clear();
		if (mAdapter == null || mAdapter.getCount() == 0) {
			return;
		}
		while (!isFinished) {
			FQView view = mRemoveQueue.poll();
			view = mAdapter.getView(index, view, getWidth(), getHeight());
			view.setFrame(0, height, mFrame.width(), height + view.getHeight());
			addView(view);
			view.mPosition = index;
			mLastView = view;
			index++;
			height += view.getHeight();
			if (height > mFrame.height()) {
				isFinished = true;
			}
		}
		mFirstView = mChild.get(0);
		mSumChildHeight = getMax();
	}
}