/*
 * Copyright (C) 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.hp.android.halcyon.zxing;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.view.View;

import com.fq.android.plus.R;
import com.google.zxing.ResultPoint;

/**
 * This view is overlaid on top of the camera preview. It adds the viewfinder
 * rectangle and partial transparency outside it, as well as the laser scanner
 * animation and result points.
 * 
 */
public final class ViewfinderView extends View {
	protected static final String TAG = "log";
	private static final int OPAQUE = 0xFF;
	/**
	 * 刷新界面的时间
	 */
	private static final long ANIMATION_DELAY = 10L;

	/**
	 * 四个绿色边角对应的长度
	 */
	private int CORNER_LENGTH;
	
	/**
	 * 四个绿色边角对应的宽度
	 */
	private static final int CORNER_WIDTH = 15;
	/**
	 * 扫描框中的中间线的宽度
	 */
	private static final int MIDDLE_LINE_WIDTH = 5;
	
	/**
	 * 扫描框中的中间线的与扫描框左右的间隙
	 */
	private static final int MIDDLE_LINE_PADDING = 40;
	
	/**
	 * 中间那条线每次刷新移动的距离
	 */
	private static final int SPEEN_DISTANCE = 5;
	
	/**
	 * 手机的屏幕密度
	 */
	private static float density;
	/**
	 * 字体大小
	 */
	private static final int TEXT_SIZE = 14;
	/**
	 * 字体距离扫描框下面的距离
	 */
	private static final int TEXT_PADDING_TOP = 30;
	
	/**
	 * 画笔对象的引用
	 */
	private Paint paint;
	
	/**
	 * 中间滑动线的最顶端位置
	 */
	private int slideTop;
	
	/**
	 * 中间滑动线的最底端位置
	 */
	//private int slideBottom;
	
	/**
	 * 将扫描的二维码拍下来，这里没有这个功能，暂时不考虑
	 */
	private Bitmap resultBitmap;
	private final int maskColor;
	private final int resultColor;
	
	//关键点
	//private final int resultPointColor;
	//private Collection<ResultPoint> possibleResultPoints;
	//private Collection<ResultPoint> lastPossibleResultPoints;

	boolean isFirst;
	
	private Bitmap mLineBmp;
	private Rect mLineRect;
	
	public ViewfinderView(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		paint = new Paint();
		maskColor = 0x99c0c1c0;//0x99000000;
		resultColor = 0xb0000000;
		//resultPointColor = 0xc0ffff00;
		//possibleResultPoints = new HashSet<ResultPoint>(5);
		
		// 将像素转换成dp
		density = context.getResources().getDisplayMetrics().density;
		CORNER_LENGTH = (int) (20 * density);
	}
	
	private Rect frame = new Rect();
	
	private int[] mLocation = new int[2];
	
	@Override
	public void onDraw(Canvas canvas) {
		Rect tmpFrame = CameraManager.get().getFramingRect();
		if (tmpFrame == null) {
			return;
		}
		frame.set(tmpFrame);
		getLocationOnScreen(mLocation);
		frame.offset(-mLocation[0], -mLocation[1]);
		
		// 初始化中间线滑动的最上边和最下边
		if(!isFirst){
			isFirst = true;
			slideTop = frame.top;
			//slideBottom = frame.bottom;
			mLineBmp = BitmapFactory.decodeResource(getResources(), R.drawable.line_zxing);
			mLineRect = new Rect(0, 0, mLineBmp.getWidth(), mLineBmp.getHeight());
		}
		
		//屏幕宽高
		int width = canvas.getWidth();
		int height = canvas.getHeight();

		paint.setColor(resultBitmap != null ? resultColor : maskColor);
		//paint.setColor(0xffffffff);
		//设置扫描框之外的颜色
		canvas.drawRect(0, 0, width, frame.top, paint);
		canvas.drawRect(0, frame.top, frame.left, frame.bottom + 1, paint);
		canvas.drawRect(frame.right + 1, frame.top, width, frame.bottom + 1,paint);
		canvas.drawRect(0, frame.bottom + 1, width, height, paint);
		

		if (resultBitmap != null) {
			// Draw the opaque result bitmap over the scanning rectangle
			paint.setAlpha(OPAQUE);
			canvas.drawBitmap(resultBitmap, frame.left, frame.top, paint);
		} else {

			//扫描框四个角
			paint.setColor(0xfff16523);
			canvas.drawRect(frame.left, frame.top, frame.left + CORNER_LENGTH,
					frame.top + CORNER_WIDTH, paint);
			canvas.drawRect(frame.left, frame.top, frame.left + CORNER_WIDTH, frame.top
					+ CORNER_LENGTH, paint);
			canvas.drawRect(frame.right - CORNER_LENGTH, frame.top, frame.right,
					frame.top + CORNER_WIDTH, paint);
			canvas.drawRect(frame.right - CORNER_WIDTH, frame.top, frame.right, frame.top
					+ CORNER_LENGTH, paint);
			canvas.drawRect(frame.left, frame.bottom - CORNER_WIDTH, frame.left
					+ CORNER_LENGTH, frame.bottom, paint);
			canvas.drawRect(frame.left, frame.bottom - CORNER_LENGTH,
					frame.left + CORNER_WIDTH, frame.bottom, paint);
			canvas.drawRect(frame.right - CORNER_LENGTH, frame.bottom - CORNER_WIDTH,
					frame.right+1, frame.bottom, paint);
			canvas.drawRect(frame.right - CORNER_WIDTH, frame.bottom - CORNER_LENGTH,
					frame.right+1, frame.bottom, paint);

			//扫描框的边框
/*			canvas.drawLine(frame.left, frame.top, frame.right, frame.top, paint);
			canvas.drawLine(frame.left, frame.bottom, frame.right, frame.bottom, paint);
			canvas.drawLine(frame.left, frame.top, frame.left, frame.bottom, paint);
			canvas.drawLine(frame.right, frame.top, frame.right, frame.bottom, paint);*/
			
			//扫描框中，扫描的线
			slideTop += SPEEN_DISTANCE;
			if(slideTop >= frame.bottom){
				slideTop = frame.top;
			}
			//canvas.drawRect(frame.left + MIDDLE_LINE_PADDING, slideTop - MIDDLE_LINE_WIDTH/2, frame.right - MIDDLE_LINE_PADDING,slideTop + MIDDLE_LINE_WIDTH/2, paint);
			Rect dst = new Rect(frame.left + MIDDLE_LINE_PADDING, slideTop - MIDDLE_LINE_WIDTH/2, frame.right - MIDDLE_LINE_PADDING,slideTop + MIDDLE_LINE_WIDTH/2);
			canvas.drawBitmap(mLineBmp, mLineRect, dst, paint);
			
			//设置扫描框下边文字说明
			paint.setColor(0xaa000000);
			paint.setTextSize(TEXT_SIZE * density);
			//paint.setAlpha(0x40);
			paint.setTypeface(Typeface.create("System", Typeface.NORMAL));
			int textLen = (int) paint.measureText("将二维码放入框内，即可自动扫描");
			canvas.drawText("将二维码放入框内，即可自动扫描", (width-textLen)/2, (float) (frame.bottom + (float)TEXT_PADDING_TOP *density), paint);

			/*不显示关键点
			Collection<ResultPoint> currentPossible = possibleResultPoints;
			Collection<ResultPoint> currentLast = lastPossibleResultPoints;
			if (currentPossible.isEmpty()) {
				lastPossibleResultPoints = null;
			} else {
				possibleResultPoints = new HashSet<ResultPoint>(5);
				lastPossibleResultPoints = currentPossible;
				paint.setAlpha(OPAQUE);
				paint.setColor(resultPointColor);
				for (ResultPoint point : currentPossible) {
					canvas.drawCircle(frame.left + point.getX(), frame.top
							+ point.getY(), 6.0f, paint);
				}
			}
			if (currentLast != null) {
				paint.setAlpha(OPAQUE / 2);
				paint.setColor(resultPointColor);
				for (ResultPoint point : currentLast) {
					canvas.drawCircle(frame.left + point.getX(), frame.top
							+ point.getY(), 3.0f, paint);
				}
			}
			*/
			
			// 只刷新扫描框的内容，其他地方不刷新
			postInvalidateDelayed(ANIMATION_DELAY, frame.left, frame.top,
					frame.right, frame.bottom);
//			invalidate();
			
		}
	}

	public void drawViewfinder() {
		resultBitmap = null;
		invalidate();
	}

	/**
	 * Draw a bitmap with the result points highlighted instead of the live
	 * scanning display.
	 * 
	 * @param barcode
	 *            An image of the decoded barcode.
	 */
	public void drawResultBitmap(Bitmap barcode) {
		resultBitmap = barcode;
		invalidate();
	}

	public void addPossibleResultPoint(ResultPoint point) {
		//possibleResultPoints.add(point);
	}

}
