package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import com.hp.android.halcyon.widgets.FastBlur;

public class MainFrameLayout extends FrameLayout {
	
	private Bitmap mBitmap;
	
	private Canvas mCanvas;

	public MainFrameLayout(Context context) {
		super(context);
	}

	public MainFrameLayout(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public MainFrameLayout(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	@Override
	protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
		super.onLayout(changed, left, top, right, bottom);
		if(mBitmap != null && !mBitmap.isRecycled()) {
			mBitmap.recycle();
			mBitmap = null;
		}
		mBitmap = Bitmap.createBitmap((int) (getMeasuredWidth() / FastBlur.FACTOR_SCAL), (int) (getMeasuredHeight() / FastBlur.FACTOR_SCAL), Bitmap.Config.ARGB_8888);
		mCanvas = new Canvas(mBitmap);
		mCanvas.translate(-getLeft() / FastBlur.FACTOR_SCAL, -getTop() / FastBlur.FACTOR_SCAL);
		mCanvas.scale(1 / FastBlur.FACTOR_SCAL, 1 / FastBlur.FACTOR_SCAL);
	}
	
	public Bitmap getBitmap(){
		super.draw(mCanvas);
		return mBitmap;
	}
	
	@Override
	public void draw(Canvas canvas) {
		super.draw(canvas);
	}
	

}
