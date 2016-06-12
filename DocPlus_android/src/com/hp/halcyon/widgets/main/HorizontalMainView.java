package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.fq.android.plus.R;

public class HorizontalMainView extends HorizontalListView {

	public interface MonthAdapter {
		public int getCountOfMonth();

		public int getCountOfDay(int position);

		public int getMonthIndex(int position);
	}

	public static int mMouthTitleHeight;

	private int mItemWidth;

	private FQBaseViewAdapter mTitleViewAdapter;

	private MonthAdapter mMonthAdapte;

	private FQListView mTitleView;

	private Bitmap mArrorBitmap;

	private DataSetObserver mMonthAdapterDataObserver = new DataSetObserver() {
		@Override
		public void onChanged() {
			if (mTitleViewAdapter != null)
				mTitleViewAdapter.notifyDataSetChanged();
		}

		@Override
		public void onInvalidated() {
			if (mTitleViewAdapter != null)
				mTitleViewAdapter.notifyDataSetChanged();
		}
	};

	public HorizontalMainView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mArrorBitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.arrow_right_home);
		mMouthTitleHeight = Tools.dip2px(context, 50);
		mTitleView = new FQListView(context);
		mTitleViewAdapter = new FQBaseViewAdapter() {
			@Override
			public FQView getView(int position, FQView convertView, int parentWidth, int parentHeight) {
				MonthView view = (MonthView) convertView;
				if (view == null) {
					view = new MonthView(getContext(), mArrorBitmap);
				}
				int widht = mItemWidth * mMonthAdapte.getCountOfDay(position);
				view.setFrame(0, 0, widht, parentHeight);
				view.setMonth(mMonthAdapte.getMonthIndex(position));
				return view;
			}

			@Override
			public int getCount() {
				return mMonthAdapte == null ? 0 : mMonthAdapte.getCountOfMonth();
			}
		};
		mTitleView.setAdapter(mTitleViewAdapter);
		mTitleView.setOrientation(LinearLayout.HORIZONTAL);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int measureHeight = getMeasuredHeight();
		if (measureHeight > 0) {
			mItemWidth = (measureHeight - mMouthTitleHeight) / 8;
			mTitleView.setFrame(0, measureHeight - mMouthTitleHeight, getMeasuredWidth(), measureHeight);
		}
	}

	public void setMonthAdapter(MonthAdapter mAdapte) {
		this.mMonthAdapte = mAdapte;
		if (mAdapte != null) {
			mAdapter.registerDataSetObserver(mMonthAdapterDataObserver);
		}
	}

	@Override
	protected ViewGroup.LayoutParams getLayoutParams(View child) {
		ViewGroup.LayoutParams layoutParams = child.getLayoutParams();
		if (layoutParams == null) {
			layoutParams = new ViewGroup.LayoutParams(mItemWidth, ViewGroup.LayoutParams.MATCH_PARENT);
		}
		return layoutParams;
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		mGestureDetector.onTouchEvent(ev);
		mTitleView.dispatchTouchEvent(ev);
		return super.dispatchTouchEvent(ev);
	}

	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
		mTitleView.draw(canvas);
	}

}
