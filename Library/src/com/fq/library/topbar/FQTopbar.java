package com.fq.library.topbar;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.fq.android.library.R;

@SuppressLint("NewApi")
public class FQTopbar extends RelativeLayout{

	public Button mLeftBtn, mRightBtn;
	public TextView mTitle;
	
	private Drawable mBackground;
	
	private String mTitleText;
	private int mTitleColor;
	private int mTitleSize;
	
	private String mLeftText;
	private int mLeftTextSize;
	private int mLeftTextColor;
	private Drawable mLeftBackground;
	
	private String mRightText;
	private int mRightTextSize;
	private int mRightTextColor;
	private Drawable mRightBackground;
	
	private LayoutParams leftParams, rightParams, titleParams;
	
	private OnTopbarClickListener onTopbarClickListener;
	public interface OnTopbarClickListener{
		public void onLeftClick();
		public void onRightClick();
	}
	
	public FQTopbar(Context context) {
		this(context, null);
	}
	
	public FQTopbar(Context context, AttributeSet attrs) {
		super(context, attrs);
		initWidgets(context, attrs);
		initListener();
	}
	
	private void initWidgets(Context context, AttributeSet attrs){
		TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.FQTopbar);
		
		mBackground = ta.getDrawable(R.styleable.FQTopbar_background);
		
		mTitleText = ta.getString(R.styleable.FQTopbar_titleText);
		mTitleSize = (int) ta.getDimension(R.styleable.FQTopbar_titleTextSize, 20);
		mTitleColor = ta.getColor(R.styleable.FQTopbar_titleTextColor, Color.BLACK);
		
		mLeftText = ta.getString(R.styleable.FQTopbar_leftText);
		mLeftTextSize = (int) ta.getDimension(R.styleable.FQTopbar_leftTextSize, 18);
		mLeftTextColor = ta.getColor(R.styleable.FQTopbar_leftTextColor, Color.BLACK);
		mLeftBackground = ta.getDrawable(R.styleable.FQTopbar_leftBackground);
		
		mRightText = ta.getString(R.styleable.FQTopbar_rightText);
		mRightTextSize = (int) ta.getDimension(R.styleable.FQTopbar_rightTextSize, 18);
		mRightTextColor = ta.getColor(R.styleable.FQTopbar_rightTextColor, Color.BLACK);
		mRightBackground = ta.getDrawable(R.styleable.FQTopbar_rightBackground);
		
		ta.recycle();
		
		mTitle = new TextView(context);
		mTitle.setText(mTitleText);
		mTitle.setTextSize(mTitleSize);
		mTitle.setTextColor(mTitleColor);
		mTitle.setGravity(Gravity.CENTER);
		
		mLeftBtn = new Button(context);
		mLeftBtn.setText(mLeftText);
		mLeftBtn.setTextSize(mLeftTextSize);
		mLeftBtn.setTextColor(mLeftTextColor);
		mLeftBtn.setBackground(mLeftBackground);
		
		mRightBtn = new Button(context);
		mRightBtn.setText(mRightText);
		mRightBtn.setTextSize(mRightTextSize);
		mRightBtn.setTextColor(mRightTextColor);
		mRightBtn.setBackground(mRightBackground);
		
		setBackground(mBackground);
		
		leftParams = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
		leftParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT, TRUE);
		addView(mLeftBtn,leftParams);
		
		rightParams = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
		rightParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, TRUE);
		addView(mRightBtn,rightParams);
		
		titleParams = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
		titleParams.addRule(RelativeLayout.CENTER_IN_PARENT, TRUE);
		addView(mTitle,titleParams);
	}
	
	private void initListener(){
		mLeftBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if (onTopbarClickListener != null) {
					onTopbarClickListener.onLeftClick();
				}
			}
		});
		
		mRightBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if (onTopbarClickListener != null) {
					onTopbarClickListener.onRightClick();
				}
			}
		});
	}
	
	public void setTopbarClickListener(OnTopbarClickListener onTopbarClickListener){
		this.onTopbarClickListener = onTopbarClickListener;
	}
}
