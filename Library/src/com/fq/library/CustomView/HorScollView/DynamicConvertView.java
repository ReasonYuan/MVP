package com.fq.library.CustomView.HorScollView;

import android.content.Context;
import android.text.TextUtils.TruncateAt;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

public class DynamicConvertView extends LinearLayout{

	private Context mContext;
	public DynamicConvertView(Context context, AttributeSet attrs,
			int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		this.mContext = context;
	}

	public DynamicConvertView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.mContext = context;
	}

	public DynamicConvertView(Context context) {
		super(context);
		this.mContext = context;
	}
	
	public  void initView(int dataSize){
		float scale = getContext().getResources().getDisplayMetrics().density;
		WindowManager wm = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
		int width = wm.getDefaultDisplay().getWidth() - (int)(5*scale+0.5);
		int itemSize = (int) (width/4 - 40);
		
		if(dataSize < 4 && dataSize > 0){
			itemSize = (int) (width/dataSize - 40);
		}
		
		for(int i = 0;i< dataSize; i++){
			TextView mTextView = new TextView(mContext);
			LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(itemSize,LinearLayout.LayoutParams.WRAP_CONTENT);
			lp.setMargins(40, 0, 0, 0);
			mTextView.setSingleLine(true);
			mTextView.setEllipsize(TruncateAt.END);
			mTextView.setGravity(Gravity.LEFT);
			mTextView.setLayoutParams(lp);
			addView(mTextView);
		}
	}
}
