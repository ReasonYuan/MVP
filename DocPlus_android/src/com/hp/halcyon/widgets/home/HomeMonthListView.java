package com.hp.halcyon.widgets.home;

import java.util.ArrayList;

import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;

import com.hp.halcyon.widgets.home.HomeView.ItemClickListener;

public class HomeMonthListView extends View implements OnClickListener{
	
	private class ViewHolder{
		
		View view;
		
		int width,heigth,min,max,group;
		
		Rect rect;
		
		public ViewHolder(View v,int g){
			this.view = v;
			this.group = g;
			rect = new Rect();
		}
		
		public void computeScroll(){
			if(mRect.intersects(min, 0, max, heigth)){
				if(width == 0) measureChild(this);
				int offset = 0;
				do {
					if(max <= mCurrentX + width){  //左边移出
						offset =  max - width - mCurrentX;
						break;
					}
					if(min >= mCurrentX ){  //左边移进
						offset =  min  - mCurrentX;
					}
				} while (false);
				rect.set(offset, 0, offset+width,heigth);
			}
		}
		
		public void draw(Canvas canvas){
			if(mRect.intersects(min, 0, max, heigth)){
				if(width == 0) measureChild(this);
				canvas.translate(rect.left, 0);
				view.draw(canvas);
				canvas.translate(-rect.left, 0);
			}
		}
	}
	
	private DataSetObserver mObserver;
	
	private HomeListViewAdapter mAdapter;
	
	private ArrayList<ViewHolder> mViews;
	
	private ArrayList<ViewHolder> mAllViews;
	
	private int mCurrentX = 0;
	
	private boolean mIsLayouted = false;
	
	private Rect mRect;
	
	private ItemClickListener mClickListener;

	private float mTouchX;
	
	public void setItemClickListener(ItemClickListener l) {
		mClickListener = l;
	}
	
	public HomeMonthListView(Context context, AttributeSet attrs) {
		super(context);
		mViews = new ArrayList<HomeMonthListView.ViewHolder>();
		mAllViews = new ArrayList<HomeMonthListView.ViewHolder>();
		mRect = new Rect();
		mObserver = new DataSetObserver() {
			@Override
			public void onChanged() {
				super.onChanged();
				setViews();
			}
			@Override
			public void onInvalidated() {
				super.onInvalidated();
			}
		};
		setOnClickListener(this);
	}


	public void scrollTo(int scrollX) {
		mCurrentX = scrollX;
		if(mCurrentX < 0 ) mCurrentX = 0;
		mRect.set(mCurrentX, 0, mCurrentX + getWidth(), getHeight());
		for (int i = 0; i < mAllViews.size(); i++) {
			ViewHolder holder = mAllViews.get(i);
			if(holder.width == 0) measureChild(holder);
			if(mRect.intersects(holder.min, 0, holder.max, holder.heigth)){
				holder.computeScroll();
				if(!mViews.contains(holder)){
					mViews.add(holder);
				}
			}
		}
		
		//移除越界
		for (int i = 0; i < mViews.size(); ) {
			ViewHolder holder = mViews.get(i);
			if(!mRect.intersects(holder.min, 0, holder.max, holder.heigth)){
				mViews.remove(i);
			}
			i++;
		}
		invalidate();
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		for (int i = 0; i < mViews.size(); i++) {
			mViews.get(i).draw(canvas);
		}
	}
	
	public void setAdapter(HomeListViewAdapter adpter){
		if(mAdapter != null){
			mAdapter.unregisterDataSetObserver(mObserver);
		}
		this.mAdapter = adpter;
		if(adpter != null){
			mAdapter.registerDataSetObserver(mObserver);
			setViews();
		}
	}
	
	
	@Override
	public void layout(int l, int t, int r, int b) {
		super.layout(l, t, r, b);
		mIsLayouted = true;
	}
	
	private void setViews(){
//		try {
//			throw new RuntimeException("发");
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
		
		if(mIsLayouted && mAdapter != null){
			mAllViews.clear();
			mViews.clear();
			int offset = 0;
			for (int i = 0; i < mAdapter.getGroupCount(); i++) {
				View view = mAdapter.getMonthView(i, null, (ViewGroup)getParent());
				ViewHolder viewHolder = new ViewHolder(view,i);
				viewHolder.min = offset;
				offset += mAdapter.getMonthViewWidth(i);
				viewHolder.max = offset;
				measureChild(viewHolder);
				mAllViews.add(viewHolder);
			}
		}
		scrollTo(mCurrentX);
	}
	
	public void measureChild(ViewHolder holderView){
		if(mIsLayouted){
			int width = getWidth();
			int heigth = getHeight();
			int widthMeasureSpec = MeasureSpec.makeMeasureSpec(width, MeasureSpec.UNSPECIFIED);
			int heightMeasureSpec = MeasureSpec.makeMeasureSpec(heigth, MeasureSpec.AT_MOST);
			holderView.view.measure(widthMeasureSpec, heightMeasureSpec);
			holderView.view.layout(0, 0,holderView.view.getMeasuredWidth(), holderView.view.getMeasuredHeight());
			holderView.width = holderView.view.getMeasuredWidth();
			holderView.heigth = holderView.view.getMeasuredHeight();
			holderView.rect.set(0, 0,holderView.width,holderView.heigth);
		}
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		if(event.getAction() == MotionEvent.ACTION_DOWN){
			mTouchX = event.getX();
		}
		boolean found = false;
		for (int i = 0; i < mViews.size(); i++) {
			ViewHolder holder = mViews.get(i);
			if(holder.rect.contains((int) mTouchX, getHeight()/2)){
				found = true;
			}
		}
		if(found){
			return super.onTouchEvent(event);
		}
		return false;
	}
	
	@Override
	public void onClick(View arg0) {
		if(mClickListener != null){
			for (int i = 0; i < mViews.size(); i++) {
				ViewHolder holder = mViews.get(i);
				if(holder.rect.contains((int) mTouchX, getHeight()/2)){
					mClickListener.onMonthViewClick(holder.group, holder.view);
				}
			}
		}
	}
	
}
