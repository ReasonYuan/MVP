package com.hp.android.halcyon.view;

import java.util.ArrayList;
import java.util.Random;

import android.content.Context;
import android.graphics.Rect;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.UserAction;
import com.fq.halcyon.logic.GetUserTotalDataLogic;
import com.fq.halcyon.logic.GetUserTotalDataLogic.OnUserTotalDataCallback;
import com.fq.lib.UserActionManger;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.TextFontUtils;

public class CloseView extends FrameLayout {

	ArrayList<UserActionItemView> mItemViews;

	private FrameLayout mItemContainer;
	private TextView mName;
	private TextView mAllRecordsCount;
	private TextView mAllPatientsCount;
	private TextView mAllDocFriendsCount;
	private TextView mAllMoneyCount;
	private View mView;
	private ScrollView mScrollView;
	private View mLayout;
	private int itemHeght = 0;

	public CloseView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public CloseView(Context context) {
		super(context);
		init();
	}
	
		@Override
		public boolean onInterceptTouchEvent(MotionEvent ev) {
			return true;
		}
	private void init() {
		itemHeght = 0;
		mView = LayoutInflater.from(getContext()).inflate(
				R.layout.activity_close, null);
		mItemContainer = (FrameLayout) mView.findViewById(R.id.close_container);

		mScrollView = (ScrollView) mView.findViewById(R.id.scrollView);
		mLayout = (View) mView.findViewById(R.id.linearLayout_close);

		mName = (TextView) mView.findViewById(R.id.doctor_name);
		mAllRecordsCount = (TextView) mView
				.findViewById(R.id.all_records_count);
		mAllPatientsCount = (TextView) mView
				.findViewById(R.id.all_patients_count);
		mAllDocFriendsCount = (TextView) mView
				.findViewById(R.id.all_doc_friends);
		mAllMoneyCount = (TextView) mView.findViewById(R.id.all_money);
//		mName.setTypeface(mFont);
		mName.setText(Constants.getUser().getName());
		TextFontUtils.setFont(mName, TextFontUtils.FONT_ELLE);
		
		new GetUserTotalDataLogic().requestUserTotalData(new OnUserTotalDataCallback() {
			public void userDataCallback(int patientCount, int recordCount,
					int dpMoney, int friendCount) {
				mAllPatientsCount.setText(patientCount == 0?"N/A":patientCount+"");
				mAllRecordsCount.setText(recordCount == 0?"N/A":recordCount+"");
				mAllMoneyCount.setText(dpMoney+"");
				mAllDocFriendsCount.setText(friendCount == 0?"N/A":friendCount+"");
			}
		});
		
		addItemView(UserActionManger.getInstance().getCloseViewActions());
		addView(mView);
		
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(800);
		startAnimation(alpha);
		
		setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			}
		});
	}

	public void addItemView(ArrayList<UserAction> historys) {
		Random random = new Random();
		mItemViews = new ArrayList<UserActionItemView>();
		for (int i = 0; i < historys.size(); i++) {
			UserAction history = historys.get(i);
			UserActionItemView itemView = new UserActionItemView(getContext());
			itemView.setGravity(i % 2 == 0 ? Gravity.RIGHT : Gravity.LEFT);
			itemView.setInfo(history.getDateStr(), history.getActionStr(),
					history.getDes());
			itemView.setTextSize(18 + random.nextInt(20),
					18 + random.nextInt(20), 14 + random.nextInt(10));

			mItemContainer.addView(itemView, new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
			mItemViews.add(itemView);
		}
	}

	boolean isfirs = true;
	
	@Override
	protected void onLayout(boolean changed, int left, int top, int right,
			int bottom) {
		super.onLayout(changed, left, top, right, bottom);
		int middle = (right - left) / 2;
		Rect oldRect = new Rect(middle - 50, 30, middle, 50);
		Random random = new Random();
		int lastBottom = 0;
		for (int i = 0; i < mItemViews.size(); i++) {
			View view = mItemViews.get(i);// .getView();
			int width = view.getWidth();
			int height = view.getHeight();
			int l = 0;
			int t = 0;
			if (i % 2 == 0) {
				l = oldRect.left - width - random.nextInt(20);
				t = oldRect.bottom;
				view.layout(l, t, l + width, t + height);
			} else {
				l = middle + random.nextInt(20);
				;
				t = oldRect.bottom + 20 - random.nextInt(40);
			}
			view.layout(l, t, l + width, t + height);

			oldRect.set(view.getLeft(), view.getLeft(), view.getRight(),
					view.getBottom());
			if(i == mItemViews.size()-1){
				lastBottom = t + height;
			}
		}
		if(isfirs){
			isfirs = false;
			mItemContainer.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, lastBottom+30));
		}
	}

	public void scrollToBottom() {
		final Handler mHandler = new Handler();

		Runnable mRunnable = new Runnable() {
			
			@Override
			public void run() {
				if (mScrollView == null || mLayout == null) {
					return;
				}

				int height = mLayout.getMeasuredHeight();
				itemHeght += 15;
				if(itemHeght < height) {
					mScrollView.scrollTo(0, itemHeght);
					mHandler.postDelayed(this, (long) (1000/60.f));
				}else{
					mScrollView.scrollTo(0, height);
					AlphaAnimation alpha = new AlphaAnimation(1, 0);
					alpha.setDuration(800);
					startAnimation(alpha);
					alpha.setAnimationListener(new AnimationListener() {
						@Override
						public void onAnimationStart(Animation animation) {
						}
						
						@Override
						public void onAnimationRepeat(Animation animation) {
						}
						
						@Override
						public void onAnimationEnd(Animation animation) {
							((ViewGroup)getParent()).removeView(CloseView.this);
						}
					});
				}
			}
		};
		mHandler.post(mRunnable);
	}
}
