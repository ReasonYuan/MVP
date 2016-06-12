package com.hp.halcyon.widgets.main;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.AlphaAnimation;

import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.HomeActivity;
import com.hp.halcyon.widgets.main.FQView.FQOnClickListener;

public class SelectMainTimeView extends FQBaseView{

	public static interface OnSelectTimeListener{
		/**
		 * yyyy-MM
		 * @param time
		 */
		public void onSelectTime(String time,String format);
	}
	
	private ArrayList<Integer> years;

	private Map<Integer, ArrayList<Integer>> mData;
	
	OnSelectTimeListener mListener;

	public SelectMainTimeView(Context context) {
		super(context);
	}

	public SelectMainTimeView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public SelectMainTimeView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
	}

	public void setData(Map<Integer, ArrayList<Integer>> data) {
		((FQListView) mViewGroup).mChild.clear();
		((FQListView) mViewGroup).mRemoveQueue.clear();
		mData = data;
		years.clear();
		Iterator<Integer> keyiIterator = data.keySet().iterator();
		while (keyiIterator.hasNext()) {
			Integer integer = keyiIterator.next();
			years.add(integer);
		}
		Collections.sort(years);
		years.add(years.get(years.size() - 1) + 1);
		((FQListView) mViewGroup).setAdapter(new FQBaseViewAdapter() {

			@Override
			public FQView getView(int position, FQView convertView, int parentWidth, int parentHeight) {
				MainTimeItem item = new MainTimeItem(getContext(),SelectMainTimeView.this);
				final int year = years.get(position);
				item.setData(String.valueOf(year), mData.get(year));
				item.setFrame(0, 0, parentWidth, Tools.dip2px(getContext(), 480));
				return item;
			}

			@Override
			public int getCount() {
				return years.size();
			}
		});
		post(new Runnable() {

			@Override
			public void run() {
				int index = 0;
				Calendar calendar = Calendar.getInstance();
				for (int i = 0; i < years.size(); i++) {
					if (years.get(i) == calendar.get(Calendar.YEAR)) {
						index = i;
					}
				}
				FQListView rootView = (FQListView) mViewGroup;
				rootView.mScroller.setFinalY(-index * Tools.dip2px(getContext(), 480));
				rootView.mScroller.computeScrollOffset();
				((FQListView) mViewGroup).computeScroll(false);
				for (int i = 0; i < rootView.mChild.size(); i++) {
					((MainTimeItem) rootView.mChild.get(i)).fadeInAnimation(400);
				}
			}
		});
	}
	
	public void fadeOut(final ICallback callback) {
		FQListView rootView = (FQListView) mViewGroup;
		for (int i = 0; i < rootView.mChild.size(); i++) {
			((MainTimeItem) rootView.mChild.get(i)).fadeOutAnimation(400);
		}
		if (callback != null) {
			postDelayed(new Runnable() {

				@Override
				public void run() {
					callback.doCallback(null);
				}
			}, 400);
		}
	}
	
	public static void startAlphaAnimation(View view){
		AlphaAnimation alpha = new AlphaAnimation(1, 0);
		alpha.setDuration(400);
		view.startAnimation(alpha);
	}

	@Override
	protected void init(Context context) {
		years = new ArrayList<Integer>();
		mViewGroup = new FQListView(context){
			@Override
			public void invalidate() {
				SelectMainTimeView.this.invalidate();
			}
		};
		
		mViewGroup.setOnClickListener(new FQOnClickListener() {
			@Override
			public void onLongPress(FQView v) {
			}
			public void onClick(FQView v) {
				((HomeActivity)getContext()).onCloseBtnClick(null);
			}
		});
	}

	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
	}

	
	public void setOnSelectTimeListener(OnSelectTimeListener l){
		mListener = l;
	}

}
