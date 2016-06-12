package com.hp.halcyon.widgets.home;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.HomeOneDayData;

public abstract class HomeListViewAdapter extends BaseAdapter {
	
	/**
	 * 每一项item是否都是一个listView
	 */
	public static final boolean USE_LISTVIEW = true;
	
	public static final int LIST_VIEW_ID = 0xff99f0;
	
	protected ArrayList<ArrayList<HomeOneDayData>> mData;
	protected ArrayList<HomeOneDayData> mDataArray;
	
	private static final int INDEX_HEADER = 0;//header view 在mRemovedViewsCache中的位置
	
	private static final int INDEX_ITEM = 1;//item view 在mRemovedViewsCache中的位置
	
	private static final int INDEX_MORE = 2;//more view 在mRemovedViewsCache中的位置
	
	private static final int HEADER_TAG = 11;
	
	private static final int ITEM_TAG = 12;
	
	private static final int MORE_TAG = 13;
	
	private List<Queue<View>> mRemovedViewsCache = new ArrayList<Queue<View>>();
	
	public HomeListViewAdapter() {
		for (int i = 0; i < 4; i++) {
			mRemovedViewsCache.add(new LinkedList<View>());
		}
	}
	
	private BaseAdapter createAdapter(int index){
		return new ItemAdapter(index);
	}

	@Override
	public View getView(int position, View converView, ViewGroup parent) {
		LinearLayout layout = null;
		int width = HomeListView.getItemWith();
		if(converView == null){
			layout = new LinearLayout(parent.getContext());
			layout.setBackgroundColor(0x0);
			layout.setLayoutParams(new ViewGroup.LayoutParams(width, ViewGroup.LayoutParams.MATCH_PARENT));
			layout.setGravity(Gravity.BOTTOM);
			layout.setOrientation(LinearLayout.VERTICAL);
			
			if(USE_LISTVIEW){
				ListView listView = new ListView(parent.getContext()){
					@Override
					public boolean onTouchEvent(MotionEvent ev) {
						return false;
					}
				};
				LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
				layoutParams.gravity = Gravity.BOTTOM;
				listView.setLayoutParams(layoutParams);
				listView.setId(LIST_VIEW_ID);
				listView.setDividerHeight(0);
				listView.setBackgroundColor(0x0);
				layout.addView(listView, layoutParams);
			}
			converView = layout;
		}
		if(USE_LISTVIEW){
			ListView listView = (ListView) converView.findViewById(LIST_VIEW_ID);
			listView.setAdapter(createAdapter(position));
		}else {
			layout = (LinearLayout) converView;
			layout.removeAllViews();
			int columnCount = getItemCount(position);

			//1.add more view
			View view = null;
			if(columnCount >= 6){
				view = getMoreView(position, mRemovedViewsCache.get(INDEX_MORE).poll(), layout);
				view.setTag(R.id.home_view_child_tag, MORE_TAG);
				layout.addView(view,getItemViewLayoutParams(view, width)); 
			}
			
			//2.add item View
			int itemCount = 0;
			for (int i = 0; i < columnCount; i++) {
				if(itemCount >= 5) break;
				view = getItemView(position, i, mRemovedViewsCache.get(INDEX_ITEM).poll(), layout);
				view.setTag(R.id.home_view_child_tag, ITEM_TAG);
				layout.addView(view,getItemViewLayoutParams(view, width));
				itemCount ++;
			}
			
			//3.add header view
			view = getHeaderView(position, mRemovedViewsCache.get(INDEX_HEADER).poll(),layout);
			view.setTag(R.id.home_view_child_tag, HEADER_TAG);
			layout.addView(view,getItemViewLayoutParams(view, width));
		}
		
		return converView;
	}
	
	
	private void cacheViews(ViewGroup group){
		ViewGroup viewGroup = group;
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
		if(!(group instanceof ListView))viewGroup.removeAllViews();
	}
	
	public void onRecycleItemView(int position,View view){
		if(USE_LISTVIEW){
			ListView listView = (ListView) view.findViewById(LIST_VIEW_ID);
			cacheViews(listView);
		}else {
			cacheViews((ViewGroup)view);
		}
	}
	
	
	private LayoutParams getItemViewLayoutParams(View view,int width){
		LayoutParams params = view.getLayoutParams();
		if(params == null){
			params = new LayoutParams(width, width);
		}
		return params;
	}
	
	private void cacheHeaderView(View headerView){
		if(headerView != null){
			mRemovedViewsCache.get(INDEX_HEADER).offer(headerView);
		}
	}
	
	private void cacheItemView(View itemView){
		if(itemView != null){
			mRemovedViewsCache.get(INDEX_ITEM).offer(itemView);
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
	
	public int getItemViewType(int position,int column) {
		int itemCount = mDataArray.get(position).getDataCount();
		if (itemCount > 5) itemCount = 6; //大于5个，加个moreView
		int count = 1;
		count += itemCount;
		if(column == count -1){ //最后一个headerView
			return 0;
		}
		if(count == 7 && column == 0){ //第一个 moreView
			return 2;
		}
		return 1;         //itemview
	}
	
	public int converPosition(int index,int position){ 
		int dataCount = 0;
		int count = itemAdapterGetCount(index);
		if(count == 7){ //0是moreView
			dataCount = 5; // 1，2，3，4，5变4，3，2，1，0
		}else {
			dataCount =  mDataArray.get(index).getDataCount() - 1;   //比如4个: 0,1,2,3变3，2，1，0
		}
		return dataCount - position;
	}
	
	public abstract int getMonthViewWidth(int group);
	
	/**
	 * 
	 * @param position
	 * @param converView
	 * @param parent
	 * @return  
	 */
	public abstract View getHeaderView(int position,View converView,ViewGroup parent);
	
	public abstract View getMoreView(int position,View converView,ViewGroup parent);
	
	public abstract View getItemView(int position,int column,View converView,ViewGroup parent);
	
	public abstract int getItemCount(int position);
	
	public abstract int[] getMainBoardList();
	
	/**
	 * @param position
	 * @param converView
	 * @param parent
	 * @return 最下面月份的View
	 */
	public abstract View getMonthView(int group,View converView,ViewGroup parent);
	
	
	public abstract int getGroupCount();
	
	
	class ItemAdapter extends BaseAdapter{

		private int index;
		
		private int getDataCount(){
			return mDataArray.get(index).getDataCount();
		}
		
		public ItemAdapter(int index){
			this.index = index;
		}
		
		@Override
		public int getViewTypeCount() {
			if(getDataCount() > 5) return 3;
			return 2;
		}
		
		@Override
		public View getView(int position, View view, ViewGroup parent) { 
			View converView = null;
			int type = getItemViewType(position);
			switch (type) {
			case 0: //最后一个headerView
				converView = getHeaderView(index, view == null ? mRemovedViewsCache.get(INDEX_HEADER).poll() : view, parent);
				converView.setTag(R.id.home_view_child_tag,HEADER_TAG);
				break;
			case 1://itemview              //倒序
				converView = getItemView(index, converPosition(index, position), view == null ? mRemovedViewsCache.get(INDEX_ITEM).poll() : view, parent); //倒序
				converView.setTag(R.id.home_view_child_tag,ITEM_TAG);
				break;
			case 2: //第一个 moreView
				converView = getMoreView(index, view == null ? mRemovedViewsCache.get(INDEX_MORE).poll() : view, parent);
				converView.setTag(R.id.home_view_child_tag,MORE_TAG);
				break;
			default:
				break;
			}
			android.widget.AbsListView.LayoutParams params = (android.widget.AbsListView.LayoutParams) converView.getLayoutParams();
			int width = HomeListView.getItemWith();
			if(params == null) params = new android.widget.AbsListView.LayoutParams(width, width);
			params.width = width;
			params.height = width;
			HomeListView.getItemWith();
			converView.setLayoutParams(params);
			return converView;
		}
		
		@Override
		public int getItemViewType(int position) {
			int count = getCount();
			if(position == count -1){ //最后一个headerView
				return 0;
			}
			if(count == 7 && position == 0){        //有moreview
				return 2;
			}
			return 1;         //itemview
		}
		
		@Override
		public long getItemId(int position) {
			return position;
		}
		
		@Override
		public Object getItem(int position) {
			return null;
		}
		
		@Override
		public int getCount() {
			return itemAdapterGetCount(index);
		}
	}
	
	private int itemAdapterGetCount(int index){
		int count = 0;
		do {
			if(mData == null) return 0;
			count = 1; //header View
			int itemCount = mDataArray.get(index).getDataCount();
			if (itemCount > 5) itemCount = 6; //大于5个，加个moreView
			count += itemCount;
		} while (false);
		return count;
	}
}
