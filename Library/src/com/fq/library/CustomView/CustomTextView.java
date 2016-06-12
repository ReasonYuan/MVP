package com.fq.library.CustomView;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.library.R;
/**
 * TextView 跑马灯效果 支持左右两侧滚动
 * @author Xi.Wang
 *
 */
public class CustomTextView extends TextView implements Runnable {

	/**
	 * 当前滚动的位置
	 */
	private int mCurrentScrollX;

	private boolean mIsStop = true;

	/**
	 * textview的宽度
	 */
	private int mTextWidth;

	/**
	 * 是否计算过宽度
	 */
	private boolean mIsMeasure = false;
	
	/**
	 * 水平滚动的方向 1从左到右 2从右到左
	 */
	private int mDirection = 1;
	
	public final static int DIRECTION_LEFT_TO_RIGHT = 1;

	public final static int DIRECTION_RIGHT_TO_LEFT = 2;
	
	private ArrayList<String> mMessageList = new ArrayList<String>();
	
	/**
	 * 计算当前消息为第几条
	 */
	private int index = 0;
	
	private String mCurrentString;
	
	private Context mContext;
	
	private FrameLayout mParent;
	
	public CustomTextView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mContext = context;
	}

	public CustomTextView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
	}

	public CustomTextView(Context context) {
		super(context);
		mContext = context;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if (!mIsMeasure) {
			getTextWidth();
			mIsMeasure = true;
		}
		int height = this.getHeight();
		if (mDirection == CustomTextView.DIRECTION_LEFT_TO_RIGHT) {
			canvas.drawText(mCurrentString, -this.getPaint().measureText(mCurrentString),height*7/8-2 ,this.getPaint());
		}else{
			canvas.drawText(mCurrentString, this.getWidth(),height*7/8-2 ,this.getPaint());
		}
		
	}

	private void initScrollX(){
		getTextWidth();
		setDirection(mDirection);
	}
	
	
	/**
	 * 1从左到右 DIRECTION_LEFT_TO_RIGHT
	 * 2从右到左 DIRECTION_RIGHT_TO_LEFT 
	 * @param direction
	 */
	public void setDirection(int direction){
		this.mDirection = direction;
	}
	
	/**
	 * 
	 * 获取文字宽度
	 */

	private int getTextWidth() {
		Paint paint = this.getPaint();
		String str = this.getText().toString();
		mTextWidth = (int) paint.measureText(str);
		return mTextWidth;
	}

	@Override
	public void run() {
		switch (mDirection) {
		case CustomTextView.DIRECTION_LEFT_TO_RIGHT:
			mCurrentScrollX -=2;
			scrollTo(mCurrentScrollX, 0);
			if (mIsStop) {
				return;
			}
			
			if (getScrollX() <= -(this.getWidth()+this.getPaint().measureText(mCurrentString))) {
				startMove();
				return;
			}
			break;
		case CustomTextView.DIRECTION_RIGHT_TO_LEFT:
			mCurrentScrollX +=2;
			scrollTo(mCurrentScrollX, 0);
			if (mIsStop) {
				return;
			}
			
			if (getScrollX() >= (this.getWidth()+this.getPaint().measureText(mCurrentString))) {
				startMove();
				return;
			}
			break;
		default:
			break;
		} 
		postDelayed(this, (long) (1000/60.0));
	}

	
	private void startScroll(){
		mIsStop = false;
		this.removeCallbacks(this);
		post(this);
	}
	
	private void stopScroll(){
		mIsStop = true;
	}
	
	/**
	 * 开始滚动
	 */
	private void startMove(){
		if (mParent != null && mMessageList.size() > 0) {
			if (mParent.getVisibility() == GONE && mMessageList.size() > 0) {
				showHomeMessageAnimation();
				index = 0;
			}
			
			mCurrentScrollX = 0;
			if (index >= mMessageList.size()) {
				this.removeCallbacks(this);
				mMessageList.clear();
				index = 0;
				stopScroll();
				 Runnable mRunnable =  new Runnable() {
					public void run() {
						hiddenHomeMessageAnimation();
					}
				};
				postDelayed(mRunnable, 1500);
				
			}else{
				mCurrentString = mMessageList.get(index);
					startScroll();
			}
			index++;
		}
		
		
	}
	
	/**
	 * 初始化文字列表
	 * @param messageList
	 * @param mParent
	 */
	public void initText(ArrayList<String> messageList,FrameLayout mParent){
		this.mMessageList = messageList;
		this.mParent = mParent;
		initScrollX();
		if (mIsStop) {
			startMove();
		}
		
	}
	
	/**
	 * 动态消息显示动画
	 */
	public void showHomeMessageAnimation(){
		Animation mAnimation = AnimationUtils.loadAnimation(mContext, R.anim.activity_anim_home_message_show);
		mParent.setVisibility(View.VISIBLE);
		mParent.startAnimation(mAnimation);
	}
	
	/**
	 * 动态消息消失动画
	 */
	public void hiddenHomeMessageAnimation(){
		Animation mAnimation = AnimationUtils.loadAnimation(mContext, R.anim.activity_anim_home_message_hidden);
		mParent.setVisibility(View.GONE);
		mParent.startAnimation(mAnimation);
	}
	
	/**
	 * 获取是否在展示状态
	 * @return
	 */
	public boolean getShowStatus(){
		return mIsStop;
	}
}
