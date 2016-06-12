package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.HorizontalScrollView;

import com.hp.halcyon.widgets.main.FQView.FQOnClickListener;
import com.hp.halcyon.widgets.main.MainViewAdapter.MainViewAdapterObserver;

public class MainView extends View implements FQOnClickListener {

	public static final int ANIMATE_DURA = 300;
	
	public HorizontalScrollView mScrollView;
	
	private FQViewGroup mRootViewGroup;

	private MainViewAdapter mAdapter;

	int mCurrentLeftPosition = 0;

	private FQView mSelectedView;

	private Rect mEffectiveArea;

	public MainView(Context context) {
		super(context);
		init(context);
	}
	
	public MainView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	public MainView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		init(context);
	}

	private void init(Context context) {
		mEffectiveArea = new Rect();
		mRootViewGroup = new FQViewGroup(context) {
			@Override
			protected void onFrameChanged() {
				mCurrentLeftPosition = 0;
				for (int i = 0; i < mRootViewGroup.mChild.size(); i++) {
					FQView child = mRootViewGroup.mChild.get(i);
					Rect mFrame = mRootViewGroup.getFrame();
					Rect frame = child.mFrame;
					child.setFrame(mCurrentLeftPosition, 0, mCurrentLeftPosition + frame.right - frame.left, mFrame.bottom - mFrame.top);
					mCurrentLeftPosition += frame.right - frame.left;// + Tools.dip2px(getContext(), 10);
				}
			}

			@Override
			protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
				super.onScroll(e1, e2, distanceX, distanceY);
				return true;
			}

			@Override
			protected void beforeDraw(Canvas canvas) {
				canvas.translate(mFrame.left , mFrame.top);
			}

			@Override
			protected void afterDraw(Canvas canvas) {
				canvas.translate(-mFrame.left, -mFrame.top);
			}

			@Override
			public void invalidate() {
				MainView.this.invalidate();
			}
			
			public Rect getEffectiveArea() {
				if (mScrollView != null) {
					mEffectiveArea.set(0, 0, mScrollView.getWidth(), mScrollView.getHeight());
					mEffectiveArea.offset(mScrollView.getScrollX(), mScrollView.getScrollY());
				}
				return mEffectiveArea;
			}
		};
	}

	public void addColumnView(MainColumnView columnView) {
		if (columnView == null){
			return;
		}
		mRootViewGroup.addView(columnView);
		Rect mFrame = mRootViewGroup.getFrame();
		Rect frame = columnView.mFrame;
		columnView.setFrame(mCurrentLeftPosition, 0, mCurrentLeftPosition + frame.right - frame.left, mFrame.bottom - mFrame.top);
		mCurrentLeftPosition += frame.right - frame.left;// + Tools.dip2px(getContext(), 10);
		columnView.setOnClickListener(this);
	}

	@Override
	public void onClick(FQView v) {
		final MainColumnView columnView = (MainColumnView) v;
		if(mSelectedView != null){
			for (int i = 0; i < mRootViewGroup.mChild.size(); i++) {
				FQView child = mRootViewGroup.mChild.get(i);
				Animate animate = child.getAnimate();
				if(animate != null){
					Animate initAnimate = new Animate(1.f, 1.f, 0, 0, ANIMATE_DURA);
					child.startAnimate(animate.append(initAnimate));
				}
			}
			if(mSelectedView == columnView){
				mSelectedView = null;
				return;
			}
		}
		mSelectedView = columnView;
		int vWidth = columnView.getWidth();
		columnView.setAnchor(0.5f, 1);
		float scale = 1.1f;
		float transX = (vWidth * (scale - 1) / 2.f);
		int selectViewleft = mSelectedView.getFrame().left;
		for (int i = 0; i < mRootViewGroup.mChild.size(); i++) {
			FQView child = mRootViewGroup.mChild.get(i);
			Animate animate = child.getAnimate();
			Animate transAnimate;
			int currentLeft = child.getFrame().left;
			if(child == mSelectedView){
				transAnimate =  new Animate(1, scale, ANIMATE_DURA);
			}else if (currentLeft < selectViewleft){
				transAnimate = new Animate(ANIMATE_DURA).setOffset(-transX, 0);
			}else{
				transAnimate = new Animate( ANIMATE_DURA).setOffset(transX, 0);
			}
			child.startAnimate(animate==null?transAnimate:animate.append(transAnimate));
		}
	}


	private MainViewAdapterObserver mObserver = new MainViewAdapterObserver() {

		@Override
		public void onDataSetChanged() {
			dataChanged();
		}

	};

	public void setAdapter(MainViewAdapter adapter) {
		this.mAdapter = adapter;
		mAdapter.registerObserver(mObserver);
		dataChanged();
	}

	private void dataChanged() {
		if (mAdapter == null)
			return;
		mRootViewGroup.mChild.clear();
		mCurrentLeftPosition = 0;
		for (int i = 0; i < mAdapter.getColumnCount(); i++) {
			MainColumnView columnView = new MainColumnView(getContext());
			//columnView.setBackgroundColor(Color.GREEN);
			this.addColumnView(columnView);
			View headerView = mAdapter.getHeaderView(i, null);
			columnView.addView(headerView);
			for (int j = 0; j < mAdapter.getCount(i); j++) {
				View child = mAdapter.getView(i, j, null);
				columnView.addView(child,10);
			}
		}
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		Rect mFrame = mRootViewGroup.getFrame();
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		mRootViewGroup.setFrame(0, 0, mCurrentLeftPosition+getMeasuredWidth(), getMeasuredHeight());
		setMeasuredDimension(mCurrentLeftPosition+getMeasuredWidth(), getMeasuredHeight());
	}
	
	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		return mRootViewGroup.dispatchTouchEvent(event);
	}

	long time;
	int fps;
	
	@Override
	public void draw(Canvas canvas) {
		//super.draw(canvas);
		mRootViewGroup.draw(canvas);
		fps++;
		long currentTime = System.currentTimeMillis();
		if(currentTime - time >= 1000){
			Log.e("", "fps:"+fps);
			fps = 0;
			time = currentTime;
		}
		invalidate();
		//postInvalidateDelayed(ANIMATION_DELAY, frame.left, frame.top,
//		frame.right, frame.bottom);
	}

	@Override
	public void onLongPress(FQView v) {
		// TODO Auto-generated method stub
		
	}

}
