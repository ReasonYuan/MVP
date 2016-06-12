package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint.Align;
import android.graphics.Paint.FontMetrics;
import android.graphics.Rect;
import android.graphics.Typeface;


public class FQStringView extends FQView{
	
	public enum Aligement{
		LEFT,
		CNETER,
		RIGHT,
		TOP,
		BOTTOM,
		H_CENTER,
		V_CENTER
	}
	private String mText;
	
	protected int mTextColor;
	
	protected int mDisEnableColor;
	
	protected int mTextNumColor;
	
	protected int mDisEnableNumColor;
	
	protected Aligement mAligement = Aligement.CNETER;
	
	public void setTextAligement(Aligement aligement) {
		if(mAligement != aligement){
			mAligement = aligement;
			this.invalidate();
		}
	}
	
	public FQStringView(Context context) {
		super(context);
	}
	
	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mPaint.setTextSize(Tools.sp2px(mContext, 18));
		mPaint.setColor(Color.BLACK);
		mPaint.setAntiAlias(true);
		mTextColor = Color.BLACK;
		mDisEnableColor = 0xFF888888;
		mTextNumColor = 0xAA000000;
		mDisEnableNumColor = 0x88888888;
	}

	public String getText() {
		return mText;
	}

	public void setText(String mText) {
		this.mText = mText;
	}
	
	public void setTypeFace(Typeface typeface){
		mPaint.setTypeface(typeface);
		/*try {
			Typeface mFont = Typeface.createFromAsset(mContext.getResources().getAssets(),fontName);
			mPaint.setTypeface(typeface);
		} catch (Exception e) {
			e.printStackTrace();
		}*/
	}
	
	public void setTextColor(int color){
		mTextColor = color;
	}
	
	public void setTextSize(int size){
		mPaint.setTextSize(Tools.sp2px(mContext, size));
	}
	
	@Override
	public void setEnable(boolean enable) {
		super.setEnable(enable);
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		if(mText != null && !mText.equals("")){
			int oClor = mPaint.getColor();
			mPaint.setColor((!mIsEnalbe || mIsPressed)?mDisEnableColor:mTextColor);
			FontMetrics fm = mPaint.getFontMetrics();  
			mPaint.setTextAlign(Align.CENTER);
			float textWidth =mPaint.measureText(mText);
			float halfWidth = getWidth()/2.f;
			float halfHeight = getHeight()/2.f;
			//TODO 实现其它的
			switch (this.mAligement) {
			case CNETER:
				canvas.drawText(mText, halfWidth, halfHeight-fm.ascent/2.f, mPaint);
				break;
			case LEFT:
				canvas.drawText(mText, textWidth/2.f, halfHeight-fm.ascent/2.f, mPaint);
				break;
			case RIGHT:
				canvas.drawText(mText, getWidth()-textWidth/2.f, halfHeight-fm.ascent/2.f, mPaint);
				break;
			default:
				break;
			}
			mPaint.setColor(oClor);
		}
	}
	
}
