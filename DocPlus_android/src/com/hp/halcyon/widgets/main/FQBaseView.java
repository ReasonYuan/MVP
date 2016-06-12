package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

public class FQBaseView extends View {

	protected FQViewGroup mViewGroup;

	public FQBaseView(Context context) {
		super(context);
		init(context);
	}

	public FQBaseView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	public FQBaseView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		init(context);
	}

	protected void init(Context context) {
		mViewGroup = new FQViewGroup(context){
			@Override
			public void invalidate() {
				FQBaseView.this.invalidate();
			}
		};
	}

	public FQViewGroup getFqViewGroup() {
		return mViewGroup;
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int measureWidth = getMeasuredWidth();
		int measureHeight = getMeasuredHeight();
		if (measureWidth == 0 || measureHeight == 0)
			return;
		mViewGroup.setFrame(0, 0, measureWidth, measureHeight);
	}

//	long time;
//	int fps;

	@Override
	public void draw(Canvas canvas) {
		if (getVisibility() != View.VISIBLE) {
			return;
		}
		mViewGroup.draw(canvas);
//		if(BuildConfig.DEBUG){
//			fps++;
//			long currentTime = System.currentTimeMillis();
//			if (currentTime - time >= 1000) {
//				Log.e("", "fps:" + fps);
//				fps = 0;
//				time = currentTime;
//			}
//		}
//		invalidate();
	}

	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		return mViewGroup.dispatchTouchEvent(event);
	}

}
