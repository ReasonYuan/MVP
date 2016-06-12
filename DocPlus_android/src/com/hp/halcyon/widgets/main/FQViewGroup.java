package com.hp.halcyon.widgets.main;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;

public class FQViewGroup extends FQView {
	
	public static class GestureListener extends SimpleOnGestureListener{
		public boolean onUp(MotionEvent e){return false;};
		public boolean onMove(MotionEvent e){return false;};
		public boolean canScroll(){return true;};
	}
	
	protected GestureDetector mGesture;

	protected FQView mHandleTarget = null;

	protected ArrayList<FQView> mChild ;

	int mInitLeft, mInitTop;
	
	protected GestureListener mGestureListener;

	public FQViewGroup(Context context) {
		super(context);
	}

	public FQViewGroup(Context context, Rect frame) {
		super(context, frame);
	}

	public FQViewGroup(Context context, int left, int top, int right, int bottom) {
		super(context, left, top, right, bottom);
	}

	
	public void setSimpleOnGestureListener(GestureListener l){
		mGestureListener  = l;
	}
	
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mRoot = this;
		mChild = new ArrayList<FQView>();
//		mBgColor = Color.WHITE;
	}

	protected void createGesture() {
		mGesture = new GestureDetector(mContext, new SimpleOnGestureListener() {

			public boolean onSingleTapUp(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onSingleTapUp(e);
				return FQViewGroup.this.onSingleTapUp(e);
			}

			public void onLongPress(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onLongPress(e);
				FQViewGroup.this.onLongPress(e);
			}

			public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
				if(mGestureListener != null) mGestureListener.onScroll(e1, e2, distanceX, distanceY);
				return FQViewGroup.this.onScroll(e1, e2, distanceX, distanceY);
			}

			public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
				if(mGestureListener != null) mGestureListener.onFling(e1, e2, velocityX, velocityY);
				FQViewGroup.this.onFling(e1, e2, velocityX, velocityY);
				return false;
			}

			public void onShowPress(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onShowPress(e);
			}

			public boolean onDown(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onDown(e);
				FQViewGroup.this.onKeyDown(e);
				return true;
			}

			public boolean onDoubleTap(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onDoubleTap(e);
				return false;
			}

			public boolean onDoubleTapEvent(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onDoubleTapEvent(e);
				return false;
			}

			public boolean onSingleTapConfirmed(MotionEvent e) {
				if(mGestureListener != null) mGestureListener.onSingleTapConfirmed(e);
				return false;
			}
		});
	}

	public boolean dispatchTouchEvent(MotionEvent event) {
		// 只有rootView派发事件
		if (mParent != null) {
			mGesture = null;
			return false;
		}
		if (mGesture == null) {
			createGesture();
		}
		mGesture.onTouchEvent(event);
		if (event.getAction() == MotionEvent.ACTION_UP) {
			this.onKeyUp(event);
		}
		return true;
	}

	protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			child.onScroll(e1, e2, distanceX, distanceY);
		}
		return true;
	}

	public void onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY){
		
	}
	
	protected FQView getTargetView(MotionEvent e) {
		FQView target = null;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			if (child instanceof FQViewGroup) {
				target = ((FQViewGroup) child).getTargetView(e);
				if (target != null)
					break;
			} else {
				if (child.canHandleSingleTapUp() && child.getAbsoluteRect().contains((int) e.getX(), (int) e.getY())) {
					target = child;
					break;
				}if( child instanceof MonthView && ((MonthView)child).arrorRectContains((int) e.getX(), (int) e.getY())){
					target = child;
					break;
				}
			}
		}
		if (target == null && getAbsoluteRect().contains((int) e.getX(), (int) e.getY())) {
			target = this;
		}
		return target;
	}

	protected FQView onKeyDown(MotionEvent e) {
		mHandleTarget = null;
		mHandleTarget = getTargetView(e);
		if (mHandleTarget != null) {
			mHandleTarget.setPressed(true);
		}
		invalidate();
		return mHandleTarget;
	}

	protected boolean onKeyUp(MotionEvent e) {
		if (mHandleTarget != null) {
			mHandleTarget.setPressed(false);
			mHandleTarget = null;
		}
		if(mGestureListener != null) mGestureListener.onUp(e);
		return false;
	}

	protected boolean onSingleTapUp(MotionEvent e) {
		if (mHandleTarget != null && mHandleTarget.canHandleSingleTapUp()) {
			mHandleTarget.onSingleTapUp(e);
		}else if(canHandleSingleTapUp()){
			super.onSingleTapUp(e);
		}
		return false;
	}

	protected boolean onLongPress(MotionEvent e) {
		if (mHandleTarget != null && mHandleTarget.canHandleSingleTapUp()) {
			mHandleTarget.onLongPress(e);
		}else if(canHandleSingleTapUp()){
			super.onLongPress(e);
		}
		return false;
	}
	
	
	@Override
	protected void onFrameChanged() {
		super.onFrameChanged();
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			child.onFrameChanged();
		}
	}

	public FQView addView(View view) {
		if (view != null) {
			FQView child = null;
			FQAndroidView androidView = new FQAndroidView(mContext);
			androidView.setView(view);
			child = androidView;
			if (child.mParent != null)
				throw new RuntimeException("subview's parent no null");
			mChild.add(child);
			child.mParent = this;
			child.setRootView(this.mParent == null ? this : this.mRoot); 
			invalidate();
			return child;
		}
		return null;
	}

	public FQView addView(FQView view) {
		if (view != null) {
			FQView child = view;
			if (child.mParent != null)
				throw new RuntimeException("subview's parent no null");
			mChild.add(child);
			child.mParent = this;
			child.setRootView(this.mParent == null ? this : this.mRoot); 
			invalidate();
			return child;
		}
		return null;
	}

	@Override
	public void draw(Canvas canvas) {
		canvas.getMatrix(mMatrix);
		mMatrix.getValues(matrixValues);
		mInitLeft = (int) matrixValues[2];
		mInitTop = (int) matrixValues[5];
		super.draw(canvas);
	}

	@Override
	protected void onDraw(Canvas canvas) {
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			child.draw(canvas);
		}
	}


	
	public void setRootView(FQViewGroup rootView){
		super.setRootView(rootView);
		for (int i = 0; i < mChild.size(); i++) {
			mChild.get(i).setRootView(rootView);
		}
	}
}
