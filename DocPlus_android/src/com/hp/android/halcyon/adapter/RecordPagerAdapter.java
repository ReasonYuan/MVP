package com.hp.android.halcyon.adapter;

import java.util.ArrayList;

import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;

import com.fq.halcyon.entity.RecordItemSamp;
import com.hp.android.halcyon.BrowRecordItemActivity;
import com.hp.android.halcyon.view.BrowRecordItemView;

public class RecordPagerAdapter extends PagerAdapter{

	private BrowRecordItemActivity mContex;
	private ViewPager mViewPager;
	private ArrayList<RecordItemSamp> recordSamps;
	private SparseArray<BrowRecordItemView> mViews = new SparseArray<BrowRecordItemView>();
	
	public RecordPagerAdapter(BrowRecordItemActivity context,ArrayList<RecordItemSamp> records, ViewPager viewPager){
		mContex = context;
		recordSamps = records;
		mViewPager = viewPager;
	}
	
	public BrowRecordItemView getCurrentView(int position){
		return mViews.get(position);
	}
	
	@Override
	public int getCount() {
		return recordSamps.size();
	}

	@Override
	public boolean isViewFromObject(View arg0, Object arg1) {
		return arg0 == arg1;
	}

	@Override
	public Object instantiateItem(ViewGroup container, int position) {
		BrowRecordItemView view = mViews.get(position);
		if(view == null){
			view = new BrowRecordItemView(mContex);
			view.setHorizontalTouch(mViewPager);
			view.initData(recordSamps.get(position));
			mViews.put(position, view);
		}
		
		container.addView(view);
		return view;
	}
	
	@Override
	public void destroyItem(ViewGroup container, int position, Object object) {
		View view = (View) object;
		container.removeView(view);
		view = null;
		if(mViews.size() > 6){
			mViews.remove(position);
		}
	}
	
}
