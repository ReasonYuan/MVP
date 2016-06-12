package com.hp.android.halcyon.widgets;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.Shader.TileMode;
import android.view.View;

import com.fq.android.plus.R;
import com.hp.halcyon.widgets.main.Tools;

/**
 *  主页识别数据的显示逻辑
 *
 */
public class DailyRecViewLogic {
	
	private static final int TOP_BOTTOM_MARGIN_PERCENT = 10;
	private float mCellWidth = 50;
	/**
	 * 实际显示屏幕上每天的识别记录数量
	 */
	private int mDailyDisRecNum[];
	/**
	 * 从服务器得到的所有记录识别数量
	 */
	private int mDailyAllRecNum[];
	
	/**
	 * 初始化一个3, 以避免用户是别数最多为<3时，比如零星的1导致主页上出现很多很高的尖尖
	 */
	private int maxY = 3;
	
	private Paint mPaintLine = null;
	private Paint mPaintDot = new Paint();
	/**
	 * 每日识别图上的圆点
	 */
	private Bitmap mBmpDailyDot;
	private Paint mPaintText = new Paint();
	/**
	 * X的起点位置
	 */
	private float mXStart = 0;
	
	private View mParent;
	private Paint mPaintEdge = new Paint();
	
	/**
	 * 识别曲线上圆点的显示大小
	 */
	private final int DOT_DIS_SIZE;
	
	private final Rect mTmpRectSrc = new Rect();
	private final Rect mTmpRectDst = new Rect();
	
	private int BOTTOM_LINE_HEIGHT;
	
	public DailyRecViewLogic(View parent, int bottomLineHeight){
		mParent = parent;
		mBmpDailyDot = BitmapFactory.decodeResource(parent.getContext().getResources(), R.drawable.daily_item_dot);
		
//		 paint.setXfermode(new
//		 PorterDuffXfermode(android.graphics.PorterDuff.Mode.DST_IN));
		
		//锚点在左边
		mPaintText.setTextAlign(Align.LEFT);
		mPaintText.setColor(Color.argb(0xFF, 173, 219, 221));
		mPaintText.setTextSize(20);
		mPaintText.setAntiAlias(true);
		
		mPaintEdge.setColor(Color.argb(0xFF, 98, 192, 195));
		mPaintEdge.setStrokeWidth(2);
		
		//12dp对应的像素
		DOT_DIS_SIZE = Tools.dip2px(parent.getContext(), 12);
		
		BOTTOM_LINE_HEIGHT = Tools.dip2px(mParent.getContext(), bottomLineHeight + 13);
	}
	
	public void setBottomLineHeight(int bottomLineHeight){
		BOTTOM_LINE_HEIGHT = Tools.dip2px(mParent.getContext(), bottomLineHeight + 13);
	}
	
	private float getWidth(){
		return mParent.getWidth();
	}
	
	private float getHeight(){
		return mParent.getHeight();
	}
	
	/**
	 * 设置主页上每天的识别数据
	 * @param dailyRecNum
	 * 		- 每天识别的具体数据，长度和主页上的天数必须一致
	 */
	public void setDailyRecData(int[] dailyRecNum){
		mDailyAllRecNum = dailyRecNum;
		for (int i = 0; i < mDailyAllRecNum.length; i++) {
			if (maxY < mDailyAllRecNum[i]) {
				maxY = mDailyAllRecNum[i];
			}
		}
	}
	
	/**
	 * 数据是否已准备好
	 * @return
	 */
	public boolean isDataReady(){
		return mDailyAllRecNum != null;
	}
	
//	/**
//	 * 设置主页上每天的识别数据
//	 * @param xStart
//	 * 		- 识别曲线的起点位置
//	 * @param cellWidth
//	 * 		- 每天 显示数据的距离(或宽度)
//	 * @param dailyRecNum
//	 * 		- 每天识别的具体数据，长度和主页上的天数必须一致
//	 */
//	public void setDailyRecData(float xStart, float cellWidth, int[] dailyRecNum){
//		mXStart = xStart;
//		mCellWidth = cellWidth;
//		mDailyDisRecNum = dailyRecNum;
//	}

	/**
	 * 滚动到要显示的识别数据
	 * @param firstShowViewPos
	 * @param lastShowViewPos
	 * @param cellWidth
	 * @param firstViewX
	 */
	public void scrollTo(int firstShowViewPos, int lastShowViewPos, int cellWidth, float firstViewX){
		mXStart = firstViewX;
		mCellWidth = cellWidth;
		
		if(mDailyAllRecNum == null || mDailyAllRecNum.length == 0){
			return;
		}
		
		int realFirst = firstShowViewPos;
		if(mDailyDisRecNum == null || mDailyDisRecNum.length != (lastShowViewPos - firstShowViewPos + 1)){
			//由于滚动过程中会出现边际空白的情况，所以要前后多取天数
			//往前多取几天
			int preExtraDays = 0;
			//往后多取几天
			int afterExtraDays = 0;
			final int MAX_EXTRA = 2;
			for (int i = 1; i <= MAX_EXTRA; i++) {
				int preIndex = firstShowViewPos - i;
				if (preIndex >= 0) {
					preExtraDays++;
				}
				int afterIndex = lastShowViewPos + i;
				if (afterIndex < mDailyAllRecNum.length - 1) {
					afterExtraDays++;
				}
			}
			mDailyDisRecNum = new int[lastShowViewPos - firstShowViewPos + 1 + preExtraDays + afterExtraDays];
			realFirst = firstShowViewPos - preExtraDays;
			mXStart -= preExtraDays*cellWidth;
		}
		
		for (int i = 0; i < mDailyDisRecNum.length; i++) {
			mDailyDisRecNum[i] = mDailyAllRecNum[realFirst + i];
		}
	}
	
	/**
	 * 根据网络数据显示识别曲线
	 * @param canvas
	 */
	public void showDailyRecLines(Canvas canvas) {
		if (mDailyDisRecNum == null) {
			return;
		}
		
		if(mPaintLine == null){
			mPaintLine = new Paint();
			mPaintLine.setAntiAlias(true);
			LinearGradient shader = new LinearGradient(getWidth() / 2, 0, getWidth()/2, getHeight() - BOTTOM_LINE_HEIGHT, Color.argb(0xFF, 225, 243, 250), 0x00FFFFFF, TileMode.CLAMP);
			mPaintLine.setShader(shader);
		}
		
		final float BOTTOM_Y = getHeight() - getHeight()/TOP_BOTTOM_MARGIN_PERCENT - BOTTOM_LINE_HEIGHT;
		final float TOP_Y = getHeight()/TOP_BOTTOM_MARGIN_PERCENT;
		final float BOTTOM_LINE_Y = getHeight() - BOTTOM_LINE_HEIGHT;
		//显示辅助数据，实际上每个点的显示位置，由每天的识别数结合屏幕高度计算而来
		float[] viewDailyHeights = new float[mDailyDisRecNum.length];
		for (int i = 0; i < viewDailyHeights.length; i++) {
			viewDailyHeights[i] = BOTTOM_Y - ((float)mDailyDisRecNum[i]) / maxY*(BOTTOM_Y-TOP_Y);
		}
		
		//第一步: 画不规则渐变半透明形状
		Path path = new Path();
		path.moveTo(mXStart, BOTTOM_LINE_Y);
		for (int i = 0; i < mDailyDisRecNum.length; i++) {
			path.lineTo(mXStart + mCellWidth * i, viewDailyHeights[i]);
		}
		path.lineTo(mXStart + mCellWidth * (mDailyDisRecNum.length - 1), BOTTOM_LINE_Y);
		canvas.drawPath(path, mPaintLine);
		
		//第二步: 画顶点上的圆点和提示
		for (int i = 0; i < mDailyDisRecNum.length; i++) {
			if(i<mDailyDisRecNum.length-1){
				canvas.drawLine(mXStart + mCellWidth * i, viewDailyHeights[i], mXStart + mCellWidth * (i+1), viewDailyHeights[i+1], mPaintEdge);
			}
			//只有前后都相等的圆圈才不显示
			if(i != 0 && i != mDailyDisRecNum.length - 1 && mDailyDisRecNum[i - 1] == mDailyDisRecNum[i] && mDailyDisRecNum[i + 1] == mDailyDisRecNum[i]){
				//如果和前一次相同，则不显示数字， 否则很多0很难看
				continue;
			} else {
				//画小圆圈
				int x = (int) (mXStart + mCellWidth * i - DOT_DIS_SIZE / 2);
				int y = (int) (viewDailyHeights[i] - DOT_DIS_SIZE / 2);
				mTmpRectDst.set(x, y, x + DOT_DIS_SIZE, y + DOT_DIS_SIZE);
				mTmpRectSrc.set(0, 0, mBmpDailyDot.getWidth(), mBmpDailyDot.getHeight());
				canvas.drawBitmap(mBmpDailyDot, mTmpRectSrc, mTmpRectDst, mPaintDot);
			}
		}
		
		//第3步: 画提示(不在上面一个循环是因为不让下一个圆圈覆盖 文字)
		for (int i = 0; i < mDailyDisRecNum.length; i++) {
			//只有前后都相等的数字才不显示
			if(i != 0 && i != mDailyDisRecNum.length - 1 && mDailyDisRecNum[i - 1] == mDailyDisRecNum[i] && mDailyDisRecNum[i + 1] == mDailyDisRecNum[i]){
				//如果前后都相等，则不显示数字， 否则很多0很难看
				continue;
			} else {
				// 画提示
				canvas.drawText(mDailyDisRecNum[i] + "份记录", mXStart + mCellWidth * i + mBmpDailyDot.getWidth() / 2,
						viewDailyHeights[i] + Math.abs(mPaintText.getFontMetrics().bottom - mPaintText.getFontMetrics().top) / 4, mPaintText);
			}
		}
	}

}
