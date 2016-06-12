package com.hp.halcyon.widgets.main;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;

import com.fq.android.plus.R;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.adapter.HomeMainAdapter2;
import com.hp.halcyon.widgets.main.FQView.FQOnClickListener;
import com.hp.halcyon.widgets.main.MainViewAdapter2.MainViewAdapterObserver;

public class MainView2 extends HorizontalScrollView implements MainViewAdapterObserver, FQOnClickListener {

	public static final int MONTH_HEIGHT_IN_DP = 50;

	protected FQMainBoardListView mViewGroup;

	public static interface OnItemClickListener {
		public void onItemClick(int monthPosition, int dayPosition, int position, FQView convertView);

		public void onLongClick(int monthPosition, int dayPosition, int position, FQView convertView);

		public void onClickEmpty(FQView v);
	}

	private static final boolean USE_ANIMATION = false;

	private static final float SCALE = 1.05f;

	public static interface OnMonthTitleClickListener {
		public void onMonthTitleClick(FQView view);

		public void onArrorClick(FQView view);
	}

	public static final int ANIMATE_DURA = 300;

	public static final int MARGINT = 5;

	private MainViewAdapter2 mAdapter;

	private FQBaseViewAdapter mListViewAdapter, mTitleViewAdapter;

	private int mMouthTitleHeight;

	private int[] mPosition = new int[2];

	private int mMargin;

	private int mSelectedViewIndex;

	private FQListView mTitleView;

	private OnMonthTitleClickListener monthTitleClickListener;

	private OnItemClickListener mOnItemClickListener;

	private Bitmap mArrorBitmap;

	MainView mView;
	
	boolean mIsLayouted;
	
	int mSumScrollTo;
	
	class MainView extends View {

		public MainView(Context context) {
			super(context);
		}

		@Override
		protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
			super.onMeasure(widthMeasureSpec, heightMeasureSpec);
			int measureHeight = getMeasuredHeight();
			if(mAdapter != null){
				setMeasuredDimension(getItemWidth(measureHeight)*getCount(), measureHeight);
			}else {
				setMeasuredDimension(getItemWidth(measureHeight)*60, measureHeight);
			}
		}

		@Override
		public boolean onTouchEvent(MotionEvent event) {
			int scrollX = MainView2.this.getScrollX();
			MotionEvent event2 = event.obtain(event);
			event2.offsetLocation(-scrollX, 0);
			mViewGroup.dispatchTouchEvent(event2);
			mTitleView.dispatchTouchEvent(event2);
			return true;
		}

		@Override
		public void draw(Canvas canvas) {
			canvas.translate(MainView2.this.getScrollX(), MainView2.this.getScrollY());
			mViewGroup.draw(canvas);
			mTitleView.draw(canvas);
		}
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int measureWidth = getMeasuredWidth();
		int measureHeight = getMeasuredHeight();
		if (measureWidth == 0 || measureHeight == 0)
			return;
		mViewGroup.setFrame(0, 0, measureWidth, measureHeight - mMouthTitleHeight);
		mTitleView.setFrame(0, measureHeight - mMouthTitleHeight, measureWidth, measureHeight);
	}

//	@Override
//	public boolean onTouchEvent(MotionEvent ev) {
//		boolean use = super.onTouchEvent(ev);
//		if (use)mView.onTouchEvent(ev);
//		return use;
//	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		boolean use = super.onInterceptTouchEvent(ev);
		if (mViewGroup.mGestureListener.canScroll()) {
			return use;
		} else {
			return false;
		}
	}

	@SuppressLint("NewApi")
	@Override
	public void computeScroll() {
		super.computeScroll();
		int scrollX = getScrollX();
		int scrollY = getScrollY();
		if(scrollX < 0) scrollX = 0;
		int max = mViewGroup.getMax();
		if(scrollX > max) scrollX = max;
		setScrollX(scrollX);
		scrollX = getScrollX();
		mViewGroup.scrollTo(scrollX, scrollY);
		mViewGroup.invalidate();
		scrollTo(scrollX, scrollY);
	}

	public MainView2(Context context) {
		super(context);
		init(context);
	}

	public MainView2(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	public MainView2(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		init(context);
	}

	public int getCount(){
		if(mAdapter != null){
			int count = 0;
			for (int i = 0; i < mAdapter.getCountOfMonth(); i++) {
				for (int j = 0; j < mAdapter.getCountOfDay(i); j++) {
					count++;
				}
			}
			return count;
		}
		return 0;
	}
	
	protected void init(Context context) {
		setHorizontalScrollBarEnabled(false);
		mArrorBitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.home_botton_right_icon);
		mSelectedViewIndex = -1;
		mMargin = Tools.dip2px(context, MARGINT);
		mView = new MainView(context);
		addView(mView);
		mMouthTitleHeight = Tools.dip2px(getContext(), MONTH_HEIGHT_IN_DP);
		mViewGroup = new FQMainBoardListView(context, MONTH_HEIGHT_IN_DP + MARGINT) {
			@Override
			protected void onComputeScroll() {
				super.onComputeScroll();
				int currX = -mScroller.getCurrX();
				int currY = -mScroller.getCurrY();
				onScrollTo(currX, currY);
			}

			@Override
			public void invalidate() {
				mView.invalidate();
			}

			protected boolean onSingleTapUp(MotionEvent e) {
				if (mHandleTarget != null && mHandleTarget.canHandleSingleTapUp()) {
					mHandleTarget.onSingleTapUp(e);
				} else if (canHandleSingleTapUp()) {
					super.onSingleTapUp(e);
				} else {
					if (mOnItemClickListener != null) {
						mOnItemClickListener.onClickEmpty(this);
					}
				}
				return false;
			}
			
			@Override
			protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
				return false;
			}
			@Override
			public void onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
			}
		};
		mTitleView = new FQListView(context) {
			@Override
			protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
				return false;
			}
			@Override
			public void onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
			}
		};
		((FQListView) mViewGroup).setOrientation(LinearLayout.HORIZONTAL);
//		mListViewAdapter = new FQBaseViewAdapter() {
//
//			@Override
//			public FQView getView(int position, FQView convertView, int parentWidth, int parentHeight) {
//				getPosition(position, mPosition);
//				final int monthPosition = mPosition[0];
//				final int dayPosition = mPosition[1];
//				int itemWidht = getItemWidth(parentHeight);
//				MainColumnView2 columnView = null;
//				if (convertView == null) {
//					columnView = new MainColumnView2(getContext());
//				} else {
//					columnView = (MainColumnView2) convertView;
//				}
//				columnView.reset(new ICallback() {
//					
//					@Override
//					public void doCallback(Object obj) {
//						mAdapter.resetItemView(0, 0, 0, (FQView)obj);
//					}
//				});
//				columnView.setHeaderView(mAdapter.getHeaderView(monthPosition, dayPosition, columnView.mHeaderView));
//				for (int i = 0; i < mAdapter.getCount(monthPosition, dayPosition); i++) {
//					if (i == 5) {
//						columnView.setMoreView(mAdapter.getMoreView(monthPosition, dayPosition, columnView.mMoreView));
//						break;
//					}
//					FQView cFqView = mAdapter.getItemView(monthPosition, dayPosition, i, columnView.mQueue.poll());
//					columnView.addView(cFqView);
//					final int p = i;
//					cFqView.setOnClickListener(new FQOnClickListener() {
//
//						@Override
//						public void onClick(FQView v) {
//							if (mOnItemClickListener != null)
//								mOnItemClickListener.onItemClick(monthPosition, dayPosition, p, v);
//						}
//
//						@Override
//						public void onLongPress(FQView v) {
//							if (mOnItemClickListener != null)
//								mOnItemClickListener.onLongClick(monthPosition, dayPosition, p, v);
//						}
//					});
//					if(mAdapter instanceof HomeMainAdapter2 && ((HomeMainAdapter2)mAdapter).isShouldScaleInHeadIcon()){
//						//登陆后主页时间轴除头像外的元素淡入淡出,时间为500毫秒，之后头像出现方式为缩放，时间为500毫秒
//						cFqView.startAnimate(new Animate(0, 1, 500));
//					}
//				}
//				if (mAdapter.isT(monthPosition, dayPosition)) {
//					columnView.setTView(mAdapter.getTView(monthPosition, dayPosition, columnView.mTView));
//				}
//				columnView.setFrame(0, 0, itemWidht, parentHeight);
//				if (USE_ANIMATION) {
//					columnView.setAnchor(0.5f, 1);
//					columnView.setOnClickListener(MainView2.this);
//					showAnimate(columnView, itemWidht, position, 0);
//				}
//				return columnView;
//			}
//
//			@Override
//			public int getCount() {
//				if (mAdapter == null) {
//					return 0;
//				} else {
//					int count = 0;
//					for (int i = 0; i < mAdapter.getCountOfMonth(); i++) {
//						for (int j = 0; j < mAdapter.getCountOfDay(i); j++) {
//							count++;
//						}
//					}
//					return count;
//				}
//			}
//		};
		mListViewAdapter = new FQMainBoardListAdapter();
		mTitleViewAdapter = new FQBaseViewAdapter() {
			@Override
			public FQView getView(int position, FQView convertView, int parentWidth, int parentHeight) {
				MonthView view = (MonthView) convertView;
				if (view == null) {
					view = new MonthView(getContext(), mArrorBitmap);
				}
				int itemWith = getItemWidth(mViewGroup.getHeight());
				int widht = itemWith * mAdapter.getCountOfDay(position);
				view.setFrame(0, 0, widht, parentHeight);
				view.setMonth(mAdapter.getMonthIndex(position));
				view.setOnClickListener(MainView2.this);
				return view;
			}

			@Override
			public int getCount() {
				return mAdapter == null ? 0 : mAdapter.getCountOfMonth();
			}
		};
		mTitleView.setAdapter(mTitleViewAdapter);
		mTitleView.setOrientation(LinearLayout.HORIZONTAL);
		((FQListView) mViewGroup).setAdapter(mListViewAdapter);
	}

	private void getPosition(int position, int pos[]) {
		int count = 0;
		for (int i = 0; i < mAdapter.getCountOfMonth(); i++) {
			for (int j = 0; j < mAdapter.getCountOfDay(i); j++) {
				if (count == position) {
					pos[0] = i;
					pos[1] = j;
					return;
				}
				count++;
			}
		}
	}

	public FQViewGroup getFqViewGroup() {
		return mViewGroup;
	}

	private void onScrollTo(int x, int y) {
		mTitleView.scrollTo(x, y);
	}

	private int getItemWidth(int measureHeight) {
		int headerheigth = measureHeight / 7;
		int leftHeigth = measureHeight - headerheigth;
		int sumMargin = leftHeigth / 15;
		int itemHeigth = (leftHeigth - sumMargin) / 7;
		return itemHeigth + mMargin;
	}

	public void setAdapter(MainViewAdapter2 adapter) {
		mAdapter = adapter;
		mAdapter.registerObserver(this);
		onDataSetChanged();
	}

	private int mLastColumns = 0;
	
	@Override
	public void onDataSetChanged() {
		mListViewAdapter.notifyDataSetChanged();
		mTitleViewAdapter.notifyDataSetChanged();
		invalidate();
		int cloums = 0;
		for (int i = 0; i < mAdapter.getCountOfMonth(); i++) {
			for (int j = 0; j < mAdapter.getCountOfDay(i); j++) {
				cloums ++;
			}
		}
		if(mLastColumns == 0 || cloums != mLastColumns){
			mIsLayouted = false;
			mView.requestLayout();
		}
		mLastColumns = cloums;
	}


	public void setOnMonthTitleClickListener(OnMonthTitleClickListener listener) {
		monthTitleClickListener = listener;
	}

	public void setOnItemClickListener(OnItemClickListener listener) {
		mOnItemClickListener = listener;
	}

	@Override
	public void onClick(FQView v) {
		if (v instanceof MonthView) {
			if (monthTitleClickListener != null) {
				if (((MonthView) v).mIsArrorRectPressed) {
					//==YY==回到今天的按钮拿出来了
//					monthTitleClickListener.onArrorClick(v);
				} else {
					monthTitleClickListener.onMonthTitleClick(v);
				}
			}
		} else {
			final FQView columnView = v;
			if (mSelectedViewIndex >= 0) {
				for (int i = 0; i < mViewGroup.mChild.size(); i++) {
					FQView child = mViewGroup.mChild.get(i);
					Animate animate = child.getAnimate();
					if (animate != null) {
						Animate initAnimate = new Animate(1.f, 1.f, 0, 0, ANIMATE_DURA);
						child.startAnimate(animate.append(initAnimate));
					}
				}
				if (mSelectedViewIndex == columnView.mPosition) {
					mSelectedViewIndex = -1;
					return;
				}
			}
			mSelectedViewIndex = columnView.mPosition;
			int vWidth = columnView.getWidth();
			columnView.setAnchor(0.5f, 1);
			float transX = (vWidth * (SCALE - 1) / 2.f);
			for (int i = 0; i < mViewGroup.mChild.size(); i++) {
				FQView child = mViewGroup.mChild.get(i);
				showAnimate(child, vWidth, child.mPosition, ANIMATE_DURA);
			}
		}
	}

	private void showAnimate(FQView view, int itemWidth, int position, int dur) {
		if (mSelectedViewIndex >= 0) {
			Animate animate = view.getAnimate();
			Animate transAnimate;
			float transX = (itemWidth * (SCALE - 1) / 2.f);
			if (position == mSelectedViewIndex) {
				transAnimate = new Animate(1, SCALE, dur);
			} else if (position < mSelectedViewIndex) {
				transAnimate = new Animate(dur).setOffset(-transX, 0);
			} else {
				transAnimate = new Animate(dur).setOffset(transX, 0);
			}
			view.startAnimate(animate == null ? transAnimate : animate.append(transAnimate));
		}
	}

	public boolean isReadyForPullStart() {
		return getScrollX() <= ((FQListView) mViewGroup).getMin();
	}

	public boolean isReadyForPullEnd() {
		return getScrollX() >= mView.getWidth()- getWidth();
	}

	@Override
	public void onLongPress(FQView v) {
		// TODO Auto-generated method stub

	}

	public int getCurrentIndex() {
		int currtX = -((FQListView) mViewGroup).mScroller.getCurrX();
		int itemWidth = getItemWidth(mViewGroup.getHeight());
		return currtX / itemWidth;
	}

	@Override
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		super.onLayout(changed, l, t, r, b);
		mIsLayouted = true;
		if(mSumScrollTo != 0){
			scrollTo(mSumScrollTo, 0);
			mSumScrollTo = 0;
		}
	}

	public void scrollToFirst(int index, boolean useAnimate) {
		float itemWidth = getItemWidth(mViewGroup.getHeight());
		int x = (int) (itemWidth * index)  ;
		if (useAnimate) {
			scrollTo(x, 0);
		} else {
			scrollTo(x, 0);
		}
		invalidate();
	}

	@Override
	public void scrollTo(int x, int y) {
		if(mIsLayouted){
			super.scrollTo(x, y);
		}else if(mSumScrollTo == 0){
			mSumScrollTo = x;
		}
	}
	
	public void selected(int index) {
		float itemWidth = getItemWidth(mViewGroup.getHeight());
		int x = (int) (itemWidth * index - getWidth() / 2.f + itemWidth / 2.f);
		scrollTo(x, 0);
	}
	
	public void scrollTo(int index, boolean useAnimate) {
		float itemWidth = getItemWidth(mViewGroup.getHeight());
		int x = (int) (itemWidth * index - getWidth() / 2.f + itemWidth / 2.f);
		if (useAnimate) {
			scrollTo(x, 0);
		} else {
			scrollTo(x, 0);
		}
		invalidate();
	}
	
	public interface OnScrollViewListener {  
//	    void onScrollChanged(ScrollState scrollType);  
	    void onScrollEnd();
	} 
	enum ScrollState{IDLE,TOUCH_SCROLL,FLING};
	private Handler mHandler;
	private OnScrollViewListener scrollViewListener;
	/**记录当前滚动的距离*/
    private int currentX = -9999999;
    /**当前滚动状态*/
//    private ScrollState scrollType = ScrollState.IDLE;
    /**滚动监听间隔*/
    private int scrollDealy = 50;
    /**滚动监听runnable*/
    private Runnable scrollRunnable = new Runnable() {
		@Override
		public void run() {
			// TODO Auto-generated method stub
			if(getScrollX()==currentX){
				//滚动停止  取消监听线程
//				scrollType = ScrollState.IDLE;
				if(scrollViewListener!=null){
//					scrollViewListener.onScrollChanged(scrollType);
					scrollViewListener.onScrollEnd();
				}
				mHandler.removeCallbacks(this);
				return;
			}else{
				//手指离开屏幕    view还在滚动的时候
//				scrollType = ScrollState.FLING;
//				if(scrollViewListener!=null){
//					scrollViewListener.onScrollChanged(scrollType);
//				}
			}
			currentX = getScrollX();
			mHandler.postDelayed(this, scrollDealy);
		}
	};
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		switch (ev.getAction()) {
		case MotionEvent.ACTION_MOVE:
//			this.scrollType = ScrollState.TOUCH_SCROLL;
//			if(scrollViewListener!=null){
//				scrollViewListener.onScrollChanged(scrollType);
//			}
			//手指在上面移动的时候   取消滚动监听线程
			mHandler.removeCallbacks(scrollRunnable);
			break;
		case MotionEvent.ACTION_UP:
			//手指移动的时候
			mHandler.post(scrollRunnable);
			break;
		}
		boolean use = super.onTouchEvent(ev);
		if (use)mView.onTouchEvent(ev);
		return use;
	}

	/**必须先调用这个方法设置Handler,不然会出错*/
	public void setHandler(Handler handler){
		this.mHandler = handler;
	}
	
	/**设置滚动监听*/
	public void setOnScrollStateChangedListener(OnScrollViewListener listener){
		this.scrollViewListener = listener;
	}
	
	class FQMainBoardListAdapter extends FQBaseViewAdapter{
		
		public int[] getDatas(){
			int[] result = new int[0]; 
			if (mAdapter != null) {
				result = ((HomeMainAdapter2)mAdapter).getMainBoardList();
			}
			return result == null ? new int[0]:result;
		}
		
		@Override
		public FQView getView(int position, FQView convertView, int parentWidth, int parentHeight) {
			getPosition(position, mPosition);
			final int monthPosition = mPosition[0];
			final int dayPosition = mPosition[1];
			int itemWidht = getItemWidth(parentHeight);
			MainColumnView2 columnView = null;
			if (convertView == null) {
				columnView = new MainColumnView2(getContext());
			} else {
				columnView = (MainColumnView2) convertView;
			}
			columnView.reset(new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					
					mAdapter.resetItemView(0, 0, 0, (FQView)obj);
				}
			});
			columnView.setHeaderView(mAdapter.getHeaderView(monthPosition, dayPosition, columnView.mHeaderView));
			for (int i = 0; i < mAdapter.getCount(monthPosition, dayPosition); i++) {
				if (i == 5) {
					columnView.setMoreView(mAdapter.getMoreView(monthPosition, dayPosition, columnView.mMoreView));
					break;
				}
				FQView cFqView = mAdapter.getItemView(monthPosition, dayPosition, i, columnView.mQueue.poll());
				columnView.addView(cFqView);
				final int p = i;
				cFqView.setOnClickListener(new FQOnClickListener() {

					@Override
					public void onClick(FQView v) {
						if (mOnItemClickListener != null)
							mOnItemClickListener.onItemClick(monthPosition, dayPosition, p, v);
					}

					@Override
					public void onLongPress(FQView v) {
						if (mOnItemClickListener != null)
							mOnItemClickListener.onLongClick(monthPosition, dayPosition, p, v);
					}
				});
				if(mAdapter instanceof HomeMainAdapter2 && ((HomeMainAdapter2)mAdapter).isShouldScaleInHeadIcon()){
					//登陆后主页时间轴除头像外的元素淡入淡出,时间为500毫秒，之后头像出现方式为缩放，时间为500毫秒
					cFqView.startAnimate(new Animate(0, 1, 500));
				}
			}
			if (mAdapter.isT(monthPosition, dayPosition)) {
				columnView.setTView(mAdapter.getTView(monthPosition, dayPosition, columnView.mTView));
			}
			columnView.setFrame(0, 0, itemWidht, parentHeight);
			if (USE_ANIMATION) {
				columnView.setAnchor(0.5f, 1);
				columnView.setOnClickListener(MainView2.this);
				showAnimate(columnView, itemWidht, position, 0);
			}
			return columnView;
		}

		@Override
		public int getCount() {
			if (mAdapter == null) {
				return 0;
			} else {
				int count = 0;
				for (int i = 0; i < mAdapter.getCountOfMonth(); i++) {
					for (int j = 0; j < mAdapter.getCountOfDay(i); j++) {
						count++;
					}
				}
				return count;
			}
		}
	}
	
	public boolean isInCenter(int index){
		int itemWidth = getItemWidth(mViewGroup.getHeight());
		int start = -mViewGroup.mScroller.getCurrX();
		Rect rect = new Rect(itemWidth * index + itemWidth*1/4 - start, 10, itemWidth * (index + 1) - itemWidth*1/4 - start, 20);
		return rect.contains(getWidth()/2, 15);
	}
}
