package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.FrameLayout;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.VisualizeCard;
import com.fq.library.cardview.FancyCoverFlow;

public class VisualizeCardView extends FrameLayout{

	private FancyCoverFlow mCardView;
	private VisualizeCardAdapter mAdapter;
	private int mSelectedPosition = 0;
	public VisualizeCardView(Context context) {
		this(context,null);
	}

	public VisualizeCardView(Context context, AttributeSet attrs) {
		super(context, attrs);
		View view = LayoutInflater.from(context).inflate(R.layout.view_record_item_card, null, false);
		addView(view);
		mCardView = (FancyCoverFlow) view.findViewById(R.id.fcf_record_item_card);
		this.mCardView.setAdapter(mAdapter = new VisualizeCardAdapter(context));
		this.mCardView.setUnselectedAlpha(0.9f);
		this.mCardView.setUnselectedSaturation(0.6f);
		this.mCardView.setUnselectedScale(0.8f);
		this.mCardView.setSpacing(0);
		this.mCardView.setMaxRotation(0);
		this.mCardView.setScaleDownGravity(0.5f);// 设置item在竖直方向的中心位置
		this.mCardView.setActionDistance(FancyCoverFlow.ACTION_DISTANCE_AUTO);
		initListener();
	}
	
	public void addDatas(ArrayList<VisualizeCard> datas){
		mAdapter.addDatas(datas);
	}
	
	/**
	 * Item点击事件
	 */
	public void setCardItemClickListener(OnCardItemClickListener onCardItemClickListener){
		this.onCardItemClickListener = onCardItemClickListener;
	}
	public interface OnCardItemClickListener{
		public void onItemClick(int position);
	}
	private OnCardItemClickListener onCardItemClickListener;
	
	public void initListener(){
		 mCardView.setOnItemSelectedListener(new OnItemSelectedListener() {
			 //获取选中页的事件
				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					mSelectedPosition = position;
					scheduleDismissOnScreenControls();
				}

				@Override
				public void onNothingSelected(AdapterView<?> parent) {
					
				}
			});
		 
		 mCardView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (mSelectedPosition != position) {
					return;
				}
				if (onCardItemClickListener != null) {
					onCardItemClickListener.onItemClick(position);
				}
			}
		});
	}
	
	/**
	 * 设置滑到到某个位置
	 * @param position
	 */
	public void scrollToPosition(int position){
		mCardView.setSelection(position,false);
	}
	
	/**
	 * Gallery 滑动停止监听方案
	 */
	private void scheduleDismissOnScreenControls() {
        mHandler.removeCallbacks(mSelectedRunner);
        mHandler.postDelayed(mSelectedRunner, 500);
	}
	
	private Handler mHandler = new Handler();
	private Runnable mSelectedRunner = new Runnable() {
		
		@Override
		public void run() {
			if (cardItemSelected != null) {
				VisualizeCard item = (VisualizeCard) mAdapter.getItem(mSelectedPosition);
				cardItemSelected.onItemSelected(item);
			}
		}
	};
	
	public interface OnCardItemSelectedListener{
		public void onItemSelected(VisualizeCard item);
	}
	
	private OnCardItemSelectedListener cardItemSelected;
	
	/**
	 * 设置滑动停止时，获取选中页的类型的回调
	 * @param cardItemSelected
	 */
	public void setItemSelectedListener(OnCardItemSelectedListener cardItemSelected){
		this.cardItemSelected = cardItemSelected;
	}
}
