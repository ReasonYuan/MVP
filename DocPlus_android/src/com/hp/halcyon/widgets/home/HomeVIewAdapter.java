package com.hp.halcyon.widgets.home;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;

import com.fq.android.plus.R;

public abstract class HomeVIewAdapter extends BaseAdapter {
	
	public interface onItemClickListener{ 
		public void onItemClick(int position,int column,View itemView);
		public void onMoreViewClick(int position,View itemView);
	} 
	
	
	private static final int INDEX_HEADER = 0;//header view 在mRemovedViewsCache中的位置
	
	private static final int INDEX_ITEM = 1;//item view 在mRemovedViewsCache中的位置
	
	private static final int INDEX_MORE = 2;//more view 在mRemovedViewsCache中的位置
	
	private static final int HEADER_TAG = 11;
	
	private static final int ITEM_TAG = 12;
	
	private static final int MORE_TAG = 13;
	
	private List<Queue<View>> mRemovedViewsCache = new ArrayList<Queue<View>>();
	
	public HomeVIewAdapter() {
		for (int i = 0; i < 3; i++) {
			mRemovedViewsCache.add(new LinkedList<View>());
		}
	}

	@Override
	public View getView(int position, View converView, ViewGroup parent) {
		LinearLayout layout = null;
		int width = 0;
		if(converView == null){
			int height = parent.getMeasuredHeight();
			width = height / 7;
			layout = new LinearLayout(parent.getContext());
			layout.setLayoutParams(new ViewGroup.LayoutParams(width, ViewGroup.LayoutParams.MATCH_PARENT));
			layout.setGravity(Gravity.BOTTOM);
			layout.setOrientation(LinearLayout.VERTICAL);
			converView = layout;
		}else {
			width = converView.getMeasuredWidth();
		}
		layout = (LinearLayout) converView;
		layout.removeAllViews();
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(width, width);
		int columnCount = getCount(position);

		//1.add more view
		if(columnCount >= 6){
			layout.addView(getMoreView(position, mRemovedViewsCache.get(INDEX_MORE).poll(), layout),params); 
		}
		
		//2.add item View
		int itemCount = 0;
		for (int i = 0; i < columnCount; i++) {
			if(itemCount >= 5) break;
			layout.addView(getItemView(position, i, mRemovedViewsCache.get(INDEX_ITEM).poll(), layout),params);
			itemCount ++;
		}
		
		//3.add header view
		layout.addView(getHeaderView(position, mRemovedViewsCache.get(INDEX_HEADER).poll(),layout),params);
		return converView;
	}
	
	
	public void onRecycleItemView(int position,View view){
		ViewGroup viewGroup = (ViewGroup) view;
		for (int i = 0; i < viewGroup.getChildCount(); i++) {
			View child = viewGroup.getChildAt(i);
			Object tagValue = (Integer) child.getTag(R.id.home_view_child_tag);
			if(tagValue != null && tagValue instanceof Integer){
				Integer tag = (Integer) tagValue;
				if(tag == HEADER_TAG){
					cacheHeaderView(child);
				}else if(tag == ITEM_TAG){
					cacheItemView(child);
				}else if (tag == MORE_TAG) {
					cacheMoreView(child);
				}
			}
		}
		viewGroup.removeAllViews();
	}
	
	
	private void cacheHeaderView(View headerView){
		if(headerView != null){
			mRemovedViewsCache.get(INDEX_HEADER).offer(headerView);
		}
	}
	
	private void cacheItemView(View headerView){
		if(headerView != null){
			mRemovedViewsCache.get(INDEX_ITEM).offer(headerView);
		}
	}
	
	private void cacheMoreView(View moreView){
		if(moreView != null){
			mRemovedViewsCache.get(INDEX_MORE).offer(moreView);
		}
	}
	
	@Override
	public long getItemId(int arg0) {
		return arg0;
	}
	
	@Override
	public Object getItem(int arg0) {
		return null;
	}
	
	public abstract View getHeaderView(int position,View converView,ViewGroup parent);
	
	public abstract View getMoreView(int position,View converView,ViewGroup parent);
	
	public abstract View getItemView(int position,int column,View converView,ViewGroup parent);
	
	public abstract int getCount(int position);
}
