package com.hp.halcyon.widgets.home;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.hp.halcyon.widgets.home.HomeListView.OnScrollListener;
import com.hp.halcyon.widgets.home.HorizontalListView.OnScrollStateChangedListener;
import com.hp.halcyon.widgets.main.Tools;

public class HomeView extends RelativeLayout implements OnScrollListener {

	private static final int MONTH_VIEW_HEIGHT = 50;// 50dp

	public enum ScrollAligment {
		LEFT, CENTER, Right
	}
	
	public interface ItemClickListener {
		public void onItemViewClick(int position, int column, View view);

		public void onMoreViewClick(int position, View view);

		public void onHeaderViewClick(int position, View view);

		public void onMonthViewClick(int group, View view);
	}

	private Rect mRect = new Rect();

	private HomeListView mListView;
	
	private HomeMonthListView mMonthListView;

	private ItemClickListener mClickListener;

	private HomeListViewAdapter mAdapter;

	private int mMonthViewHeight;

	private boolean mIsScrolling = false;
	
	
	private OnScrollStateChangedListener mStateChangedListener; 

	public HomeView(Context context) {
		super(context);
		init(context);
	}
	

	public void setItemClickListener(ItemClickListener l) {
		mClickListener = l;
		mMonthListView.setItemClickListener(l);
	}

	public HomeView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	public HomeView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init(context);
	}

	protected void init(Context context) {
		mListView = new HomeListView(context);
		mMonthViewHeight = Tools.dip2px(context, MONTH_VIEW_HEIGHT);
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
		params.setMargins(0, 0, 0, mMonthViewHeight);
		this.addView(mListView, params);

		mMonthListView = new HomeMonthListView(context, null);
		params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, mMonthViewHeight);
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		this.addView(mMonthListView, params);
		
		mListView.setOnScrollListener(this);
		mListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				if (mClickListener == null)
					return;
				LinearLayout layout = (LinearLayout) arg1;
				ViewGroup group = layout;
				int marginTop = 0;
				if (HomeListViewAdapter.USE_LISTVIEW) {
					ListView listView = (ListView) layout.findViewById(HomeListViewAdapter.LIST_VIEW_ID);
					group = listView;
					listView.getHitRect(mRect);
					marginTop = mRect.top;
				}
				for (int i = 0; i < group.getChildCount(); i++) {
					View view = group.getChildAt(i);
					view.getHitRect(mRect);
					if (mRect.contains(1, (int) mListView.mTouchDownY - marginTop)) {
						int type = mAdapter.getItemViewType(arg2, i);
						switch (type) {
						case 0:
							mClickListener.onHeaderViewClick(arg2, view);
							break;
						case 1:
							mClickListener.onItemViewClick(arg2, mAdapter.converPosition(arg2, i), view);
							break;
						case 2:
							mClickListener.onMoreViewClick(arg2, view);
							break;

						default:
							break;
						}
						break;
					}
				}
			}
		});
		mListView.setOnScrollStateChangedListener(new OnScrollStateChangedListener() {

			@Override
			public void onScrollStateChanged(ScrollState scrollState) {
				if(mStateChangedListener != null) mStateChangedListener.onScrollStateChanged(scrollState);
				if (scrollState == ScrollState.SCROLL_STATE_IDLE) {
					mIsScrolling = false;
				} else {
					mIsScrolling = true;
				}
			}
		});
	}

	public void setOnScrollStateChangedListener(OnScrollStateChangedListener l){
		mStateChangedListener = l;
	}
	


	public void setAdapter(HomeListViewAdapter adapter) {
		if (adapter != null) {
			mAdapter = adapter;
			mListView.setAdapter(adapter);
			mMonthListView.setAdapter(adapter);
		}
	}


	@Override
	public void onScroll(HorizontalListView listView, int scrollX) {
		mMonthListView.scrollTo(scrollX);
	}

	public boolean isReadyForPullStart() {
		if (mIsScrolling)
			return false;
		return mListView.mCurrentX == 0;
	}

	public boolean isReadyForPullEnd() {
		if (mIsScrolling)
			return false;
		return mListView.getLastVisiblePosition() == (mAdapter.getCount() - 1);
	}

	/**
	 * 把第几项移动到屏幕正中
	 * 
	 * @param index
	 * @param animation
	 */
	public void scrollTo(int index,boolean animation) {
		scrollTo(index, ScrollAligment.CENTER,animation);
	}

	public void scrollTo(int index, ScrollAligment aligment,boolean animation) {
		int width = getWidth();
		int halfWidth = width / 2;
		int itemWidth = HomeListView.getItemWith();
		int x = itemWidth * index ;
		switch (aligment) {
		case CENTER:
		{
			x += itemWidth / 2;
			do {
				if (x <= halfWidth) {
					mListView.scrollTo(0, animation);
					break;
				}
				int maxX = itemWidth * mAdapter.getCount() - width;
				if (x >= maxX) {
					mListView.scrollTo(maxX, animation);
					break;
				}
				mListView.scrollTo(x - halfWidth, animation);
			} while (false);
		}
			break;
		case LEFT:
		{
			mListView.scrollTo(x , animation);
		}
			break;
		case Right:
		{
			mListView.scrollTo(x - width, animation);
		}
			break;

		default:
			break;
		}
	}
	
	public int getCurrentIndex() {
		int currtX = mListView.mCurrentX;
		int itemWidth = HomeListView.getItemWith();
		return currtX / itemWidth;
	}

	public boolean isInCenter(int index){
		int itemWidth = HomeListView.getItemWith();
		int start =  mListView.mCurrentX;
		Rect rect = new Rect(itemWidth * index + itemWidth*1/4 - start, 10, itemWidth * (index + 1) - itemWidth*1/4 - start, 20);
		return rect.contains(getWidth()/2, 15);
	}
	
}
