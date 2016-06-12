package com.hp.android.halcyon.camerahelp;
//javaapk.com�ṩ����
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import com.fq.android.plus.R;
import com.hp.halcyon.widgets.main.Tools;

/**
 * 
 * @author huyx
 * @desc ��Ӱ����view
 */
public class ClipView extends View {
	private int swidth;
	private int sheght;
	private static  final int SIZE_SACLE = 5;
	public ClipView(Context context) {
		super(context);
	}

	public ClipView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public ClipView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		int width = this.getWidth();
		int height = this.getHeight();
		swidth = Tools.dip2px(getContext(), 10);
		sheght = Tools.dip2px(getContext(), width/10);
		if(Tools.dip2px(getContext(), 1) >= 3){
			sheght = Tools.dip2px(getContext(), width/20);
		}
		Paint paint = new Paint();
		paint.setColor(0xaa000000);
		canvas.drawRect(0, 0, width, height / SIZE_SACLE, paint);
		canvas.drawRect(0, height / SIZE_SACLE, (width - height / 2.5f) / 2,
				height * 3 / SIZE_SACLE, paint);
		canvas.drawRect((width + height / 2.5f) / 2, height / SIZE_SACLE, width,
				height * 3 / SIZE_SACLE, paint);
		canvas.drawRect(0, height * 3 / SIZE_SACLE, width, height, paint);
		
		
		paint.setColor(getResources().getColor(R.color.app_pink));
		
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height / SIZE_SACLE - 1,
				(width + height / 2.5f) / 2 + 1, (height / SIZE_SACLE), paint);
		//上方左边 
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height / SIZE_SACLE - 1,
				(width - height / 2.5f) / 2 - 1 + sheght, height / SIZE_SACLE - 1 + swidth, paint);
		//左方左边
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height / SIZE_SACLE - 1,
				(width - height / 2.5f) / 2 - 1 + swidth, height / SIZE_SACLE - 1 + sheght, paint);
	
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height / SIZE_SACLE,
				(width - height / 2.5f) / 2, height * 3 / SIZE_SACLE, paint);
		
		//左边下方
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height * 3 / SIZE_SACLE - swidth,
				(width - height / 2.5f) / 2 - 1 + sheght , height * 3 / SIZE_SACLE + 1, paint);
		//左边下方左边
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height * 3 / SIZE_SACLE - sheght,
				(width - height / 2.5f) / 2 - 1 + swidth , height * 3 / SIZE_SACLE + 1, paint);
		
		
		canvas.drawRect((width + height / 2.5f) / 2, height / SIZE_SACLE,
				(width + height / 2.5f) / 2 + 1, height * 3 / SIZE_SACLE, paint);
		//右边上方右边
		canvas.drawRect((width + height / 2.5f) / 2 -1-swidth, height / SIZE_SACLE -1,
				(width + height / 2.5f) / 2 + 1, height / SIZE_SACLE -1 +sheght, paint);
		//右边上方上方
		canvas.drawRect((width + height / 2.5f) / 2 -1-sheght, height / SIZE_SACLE -1,
				(width + height / 2.5f) / 2 + 1, height / SIZE_SACLE -1 + swidth, paint);
		
		canvas.drawRect((width - height / 2.5f) / 2 - 1, height * 3 / SIZE_SACLE,
				(width + height / 2.5f) / 2 + 1, height * 3 / SIZE_SACLE + 1, paint);
		
		//下方右边
		canvas.drawRect((width + height / 2.5f) / 2 -1-swidth, height * 3 / SIZE_SACLE - 1 -sheght,
				(width + height / 2.5f) / 2 + 1, height * 3 / SIZE_SACLE + 1, paint);
		
		canvas.drawRect((width + height / 2.5f) / 2 -1-sheght, height * 3 / SIZE_SACLE - 1-swidth ,
				(width + height / 2.5f) / 2 + 1, height * 3 / SIZE_SACLE + 1, paint);
	}

}
