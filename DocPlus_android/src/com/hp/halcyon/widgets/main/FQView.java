package com.hp.halcyon.widgets.main;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.animation.Transformation;

import com.hp.halcyon.widgets.main.Animate.AnimateListener;

public class FQView {

	public interface FQOnClickListener {
		void onClick(FQView v);
		void onLongPress(FQView v);
	}

	protected Animate mCurrentAnimate = null;

	protected FQViewGroup mParent = null;

	protected FQViewGroup mRoot = null;

	/**
	 * 绘图坐标，相对于parent的rect
	 */
	protected Rect mFrame;

	protected Rect mTmpRect;

	protected boolean mClipsubviews = true;

	protected Transformation mTransformation;

	protected FQOnClickListener mOnClickListener;

	protected Matrix mMatrix;

	protected PointF mAnchorPoint;

	protected int mBgColor;

	protected Paint mPaint;

	protected Context mContext;
	
	protected int mId;
	
	protected int mPosition;

	protected boolean mIsEnalbe = true;
	
	protected boolean mIsPressed = false;

	public FQView(Context context) {
		init(context, new Rect());
	}

	public FQView(Context context, Rect frame) {
		init(context, new Rect(frame));
	}

	public FQView(Context context, int left, int top, int right, int bottom) {
		init(context, new Rect(left, top, right, bottom));
	}

	public void setWidth(int width) {
		mFrame.set(mFrame.left, mFrame.top, mFrame.left + width, mFrame.bottom);
		onFrameChanged();
	}

	public void setHeight(int height) {
		mFrame.set(mFrame.left, mFrame.top, mFrame.left, mFrame.bottom + height);
		onFrameChanged();
	}

	public void setFrame(Rect frame) {
		mFrame.set(frame);
		onFrameChanged();
	}

	public void setFrame(int left, int top, int right, int bottom) {
		mFrame.set(left, top, right, bottom);
		onFrameChanged();
	}

	public void setPosition(int x, int y) {
		mFrame.offsetTo(x, y);
	}
	
	public void setPositionY(int y) {
		mFrame.offsetTo(mFrame.left, y);
	}

	protected void onFrameChanged() {
		invalidate();
	}

	protected void init(Context context, Rect frame) {
		mFrame = frame;
		mTmpRect = new Rect(mFrame);
		mMatrix = new Matrix();
		mTransformation = new Transformation();
		mAnchorPoint = new PointF(0.5f, 0.5f);
		mBgColor = 0x00000000;
		mPaint = new Paint();
		mPaint.setColor(mBgColor);
		mContext = context;
	}
	
	public Context getContext(){
		return mContext;
	}

	protected Transformation getTransformationInfo() {
		mTransformation.clear();
		mTransformation.getMatrix().preTranslate(mFrame.left, mFrame.top);
		return mTransformation;
	}

	protected void beforeDraw(Canvas canvas) {
		canvas.save();
		getTransformationInfo();
		if (mCurrentAnimate != null) {
			mTransformation.compose(mCurrentAnimate.getTransformation(this));
			mCurrentAnimate.getTransformation(this);
		}
		canvas.concat(mTransformation.getMatrix());
		if (mClipsubviews) {
			mTmpRect.set(mFrame);
			mTmpRect.offsetTo(0, 0);
			canvas.clipRect(mTmpRect);
		}
	}

	protected void afterDraw(Canvas canvas) {
		if (mCurrentAnimate != null) {
			if (!mCurrentAnimate.isFinished()) {
				invalidate();
			} else {
				mCurrentAnimate.animateEnd();
			}
		}
		canvas.restore();
	}

	protected void onDraw(Canvas canvas) {
	}

	protected void drawBackground(Canvas canvas) {
		mTmpRect.set(mFrame);
		mTmpRect.offsetTo(0, 0);
		int color = mBgColor;
		mPaint.setColor(mBgColor);
		canvas.drawRect(mTmpRect, mPaint);
		mPaint.setColor(color);
	}

	@SuppressWarnings("deprecation")
	@SuppressLint("WrongCall")
	public void draw(Canvas canvas) {
		beforeDraw(canvas);
		canvas.getMatrix(mMatrix);
		if (mBgColor != 0) {
			drawBackground(canvas);
		}
		onDraw(canvas);
		afterDraw(canvas);
	}

	public void setBackgroundColor(int color) {
		mBgColor = color;
		mPaint.setColor(mBgColor);
		invalidate();
	}

	public void invalidate() {
		if (mParent != null) {
			mParent.invalidate();
		}
	}

	public boolean isClipsubviews() {
		return mClipsubviews;
	}

	public void setOnClickListener(FQOnClickListener l) {
		mOnClickListener = l;
	}

	public void setClipsubviews(boolean clipsubview) {
		this.mClipsubviews = clipsubview;
	}

	public FQView getParentView() {
		return mParent;
	}

	protected static float[] matrixValues = new float[9];

	/**
	 * 得到相对rootView的Rect区域（用来进行逻辑计算）<br>
	 * 只考虑到scale引起的坐标变化
	 * 
	 * @return
	 */
	public Rect getAbsoluteRect() {
		int rootLeft = mRoot.mInitLeft;
		int rootTop = mRoot.mInitTop;
		int with = mFrame.right - mFrame.left;
		int height = mFrame.bottom - mFrame.top;
		mMatrix.getValues(matrixValues);
		int left = (int) matrixValues[2] - rootLeft;
		int top = (int) matrixValues[5] - rootTop;
		mTmpRect.set(left, top, left + (int) (with * matrixValues[0]), (int) (top + height * matrixValues[4]));
		return mTmpRect;
	}

	public Rect getFrame() {
		mTmpRect.set(mFrame);
		return mTmpRect;
	}

	public int getWidth() {
		return mFrame.right - mFrame.left;
	}

	public int getHeight() {
		return mFrame.bottom - mFrame.top;
	}

	protected boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
		return false;
	}

	protected FQView onKeyDown(MotionEvent e) {
		return null;
	}

	protected boolean onKeyUp(MotionEvent e) {
		return false;
	}

	protected boolean canHandleSingleTapUp() {
		return mIsEnalbe && mOnClickListener != null;
	}

	protected boolean onSingleTapUp(MotionEvent e) {
		if (mOnClickListener != null) {
			mOnClickListener.onClick(this);
		}
		return false;
	}
	
	protected boolean onLongPress(MotionEvent e) {
		if (mOnClickListener != null) {
			mOnClickListener.onLongPress(this);
		}
		return false;
	}
	

	/**
	 * 缩放,旋转的中心点
	 * 
	 * @param pointX
	 *            x的锚点0 ~ 1,默认0.5
	 * @param pointY
	 *            y的锚点0 ~ 1
	 */
	public void setAnchor(float pointX, float pointY) {
		mAnchorPoint.set(pointX, pointY);
	}

	public void startAnimate(Animate animate) {
		mCurrentAnimate = animate;
		animate.start();
		invalidate();
	}

	public void clearAnimate(boolean useAnimate) {
		if (mCurrentAnimate != null) {
			if (useAnimate) {
				Animate sAnimate = mCurrentAnimate.recover();
				sAnimate.setAnimateListener(new AnimateListener() {

					@Override
					public void onAnimationStart(Animate animate) {
					}

					@Override
					public void onAnimationEnd(Animate animate) {
						mCurrentAnimate = null;
						invalidate();
					}
				});
				startAnimate(sAnimate);
			} else {
				mCurrentAnimate = null;
				invalidate();
			}
		}
	}

	public void cleanAnimae() {
		mCurrentAnimate = null;
		invalidate();
	}

	public Animate getAnimate() {
		return mCurrentAnimate;
	}

	public void setPressed(boolean b) {
		mIsPressed = b;
	}

	public int getId() {
		return mId;
	}

	public void setId(int id) {
		this.mId = id;
	}
	
	protected void onComputeScroll(){
		
	};
	
	public void setEnable(boolean enable) {
		mIsEnalbe = enable;
	}
	
	public void setRootView(FQViewGroup rootView){
		mRoot = rootView;
	}
	
}
