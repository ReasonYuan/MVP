package com.hp.android.halcyon.widgets;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.FrameLayout;

public class TakePhotoBorderFrameLayout extends FrameLayout {
	
	private Paint paint = new Paint();
	boolean isInited = false;

	public TakePhotoBorderFrameLayout(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public TakePhotoBorderFrameLayout(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public TakePhotoBorderFrameLayout(Context context) {
		super(context);
	}
	
	@Override
	public void onDraw(Canvas canvas) {
		super.onDraw(canvas);
	}
	
	@Override
	protected void dispatchDraw(Canvas canvas) {
		super.dispatchDraw(canvas);
		//paint.setColor(Color.GREEN);
		//paint.setStyle(Style.STROKE);
		//canvas.drawRect(1, 1, canvas.getWidth()-2, canvas.getHeight()-2, paint);
	}

}
