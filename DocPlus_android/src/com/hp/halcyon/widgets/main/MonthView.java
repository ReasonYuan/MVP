package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.FontMetrics;
import android.graphics.Rect;

import com.hp.android.halcyon.util.TextFontUtils;

public class MonthView extends FQStringView {
	
	private static final int NUMNER_TEXT_SIZE = 46;
	
	private static final int TEXT_SIZE = 24;
	
	private static final String[] MONTH_EN = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	
	private static final String[] MONTH_ZH = {"一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"};
	
	private int mMonth = 0;
	
	private int mNumberTextSize;
	
	private int mTextSize;
	
	private int mMargin;
	
	private int mTextWidth;
	
	private int mOffset,mDBitmapWidth,mDBitmapHeigth;
	
	private Bitmap mArrorBitmap;
	
//	private Rect mArrorRect;
	
	protected boolean mIsArrorRectPressed;
	
	private Paint mPaintMonthNum;
	
	private Paint mPaintMonthEn;
	
	private int mArrorMargin;
	
	/**
	 * 0表示英语，其他中文
	 */
	private byte mType;
	
	public MonthView(Context context,Bitmap bitmap) {
		super(context);
		mArrorBitmap = bitmap;
//		mArrorRect = new Rect();
	}
	
	public void setMonth(int month){
		mMonth = month;
		mTextWidth = measureWidth();
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mNumberTextSize = Tools.sp2px(mContext, NUMNER_TEXT_SIZE);
		mTextSize = Tools.sp2px(mContext, TEXT_SIZE);
		mMargin = Tools.dip2px(mContext, 5);
		mArrorMargin = Tools.dip2px(context, 20);
		mPaint.setColor(Color.BLACK);
		mPaint.setAntiAlias(true);
		mPaint.setFilterBitmap(true);
		mType = 0;
		mPaintMonthNum = new Paint();
		mPaintMonthEn = new Paint();
		
		mPaintMonthNum.setColor(Color.BLACK);
		mPaintMonthNum.setAntiAlias(true);
		mPaintMonthNum.setFilterBitmap(true);
		
		mPaintMonthEn.setColor(Color.BLACK);
		mPaintMonthEn.setAntiAlias(true);
		mPaintMonthEn.setFilterBitmap(true);
		TextFontUtils.setPaintFont(mPaintMonthEn, TextFontUtils.FONT_ELLE_BOL);
		TextFontUtils.setPaintFont(mPaintMonthNum, TextFontUtils.FONT_HIRAGINO_SANS_GB_W3);
	}
	
	@Override
	protected void onFrameChanged() {
		super.onFrameChanged();
		mDBitmapHeigth = getHeight()/3;
		mDBitmapWidth = mDBitmapHeigth*mArrorBitmap.getWidth()/mArrorBitmap.getHeight();
	}
	
	@Override
	protected void onComputeScroll() {
		if(mParent instanceof FQListView){
			FQListView parent = (FQListView) mParent;
			if( mFrame.left < parent.mConmputeRect.left){
				int x =  parent.mConmputeRect.left - mFrame.left;
				if(x > mFrame.width() - mTextWidth){
					x = mFrame.width() - mTextWidth;
				}
				mOffset = x;
			}else {
				mOffset = 0;
			}
		}
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		String text = String.valueOf(mMonth);
		mPaint.setColor(((!mIsEnalbe || mIsPressed) && !mIsArrorRectPressed)?mDisEnableColor:mTextColor);
		mPaint.setTextSize(mNumberTextSize);
		mPaint.setTextAlign(Align.CENTER);
		
		mPaintMonthNum.setColor(((!mIsEnalbe || mIsPressed) && !mIsArrorRectPressed)?mDisEnableNumColor:mTextNumColor);
		mPaintMonthNum.setTextSize(mNumberTextSize);
		float width = mPaintMonthNum.measureText(text);
		FontMetrics fm = mPaintMonthNum.getFontMetrics();  
		mPaintMonthNum.setTextAlign(Align.CENTER);
		
		
		mPaintMonthEn.setColor(((!mIsEnalbe || mIsPressed) && !mIsArrorRectPressed)?mDisEnableColor:mTextColor);
		mPaintMonthEn.setTextSize(mNumberTextSize);
		mPaintMonthEn.setTextAlign(Align.CENTER);
		
		float halfHeight = getHeight()/2.f;
		
		canvas.drawText(text, mMargin+mOffset+width/2, halfHeight-fm.ascent/2.f, mPaintMonthNum);
		
		mPaintMonthEn.setTextSize(mTextSize);
		if(mType == 0){
			text = MONTH_EN[mMonth - 1];
		}else {
			text = MONTH_ZH[mMonth - 1];
		}
		mPaintMonthEn.setTextAlign(Align.LEFT);
		width += mMargin*2;
		fm = mPaintMonthEn.getFontMetrics();  
	//	
		canvas.drawText(text, mOffset+width, halfHeight-fm.ascent/2.f, mPaintMonthEn);
		//==YY==右边的向右箭头，不需要了
//		mTmpRect.set(0, 0, mArrorBitmap.getWidth(), mArrorBitmap.getHeight());
//		int arrorRight = mOffset + mParent.mFrame.width() - mMargin - mArrorMargin;
//		int bitmapDrawHeight = mFrame.height()*2/3;
//		int bitmapDrawWidth =(int)(mDBitmapWidth * (bitmapDrawHeight / (float)mDBitmapHeigth));
//		int left = arrorRight - mDBitmapWidth;
//		int top = (mFrame.height() - bitmapDrawHeight)/2;
//		mArrorRect.set(left, top, left + bitmapDrawWidth, top + bitmapDrawHeight);
//		canvas.drawBitmap(mArrorBitmap, mTmpRect, mArrorRect, mPaint);
	}
	
	private int measureWidth(){
		String text = String.valueOf(mMonth);
		mPaint.setTextSize(mNumberTextSize);
		float width = mPaint.measureText(text);
		width += mMargin*2;
		mPaint.setTextSize(mTextSize);
		if(mType == 0){
			width += mPaint.measureText(MONTH_EN[mMonth - 1]);
		}else {
			width += mPaint.measureText(MONTH_ZH[mMonth - 1]);
		}
		return (int) width;
	}
	
	@Override
	public Rect getAbsoluteRect() {
		mIsArrorRectPressed = false;
		int rootLeft = mRoot.mInitLeft;
		int rootTop = mRoot.mInitTop;
		int with = mTextWidth;
		int height = mFrame.bottom - mFrame.top;
		mMatrix.getValues(matrixValues);
		int left = (int) matrixValues[2] - rootLeft + mOffset;
		int top = (int) matrixValues[5] - rootTop;
		mTmpRect.set(left, top, left + (int) (with * matrixValues[0]), (int) (top + height * matrixValues[4]));
		return mTmpRect;
	}
	
	public boolean arrorRectContains(int x, int y) {
		int bitmapDrawHeight = mFrame.height()*2/3;
		int bitmapDrawWidth =(int)(mDBitmapWidth * (bitmapDrawHeight / (float)mDBitmapHeigth));
		int arrorRight = mTmpRect.left + mParent.mFrame.width() - mMargin - mArrorMargin;
		int left = arrorRight - bitmapDrawWidth*2;
		int rootTop = mRoot.mInitTop;
		int top = (int) matrixValues[5] - rootTop;
		int height = mFrame.bottom - mFrame.top;
		mTmpRect.set(left, top, left + bitmapDrawWidth*3, (int) (top + height * matrixValues[4]));
		mIsArrorRectPressed = mTmpRect.contains(x, y);
		return mIsArrorRectPressed;
	}
}
