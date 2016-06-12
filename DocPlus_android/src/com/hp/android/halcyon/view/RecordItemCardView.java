package com.hp.android.halcyon.view;

import java.util.ArrayList;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.Button;
import android.widget.FrameLayout;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.halcyon.logic2.RemoveRecordItemLogic;
import com.fq.halcyon.logic2.RemoveRecordItemLogic.RemoveItemCallBack;
import com.fq.library.cardview.FancyCoverFlow;
import com.hp.android.halcyon.adapter.RecordItemCardAdapter;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

/**
 * 浏览病历记录的卡片View
 * @author niko
 *
 */
public class RecordItemCardView extends FrameLayout{
	
	private FancyCoverFlow mCardView;
	private RecordItemCardAdapter mAdapter;
	private int mSelectedPosition = 0;
	private boolean mIsScroll;
	private ArrayList<RecordItemSamp> itemList = new ArrayList<RecordItemSamp>();
	private RemoveRecordItemLogic mRemoveLogic;
	private RecordItemSamp mDelItemSamp;
	
	CustomProgressDialog mProgressDialog;
	
	public RecordItemCardView(Context context) {
		this(context, null);
	}
	
	public RecordItemCardView(Context context, AttributeSet attrs) {
		super(context, attrs);
		View view = LayoutInflater.from(context).inflate(R.layout.view_record_item_card, null, false);
		addView(view);
		mCardView = (FancyCoverFlow) view.findViewById(R.id.fcf_record_item_card);
		this.mCardView.setAdapter(mAdapter = new RecordItemCardAdapter(context));
		this.mCardView.setUnselectedAlpha(0.9f);
		this.mCardView.setUnselectedSaturation(0.6f);
		this.mCardView.setUnselectedScale(0.8f);
		this.mCardView.setSpacing(0);
		this.mCardView.setMaxRotation(0);
		this.mCardView.setScaleDownGravity(0.5f);// 设置item在竖直方向的中心位置
		this.mCardView.setActionDistance(FancyCoverFlow.ACTION_DISTANCE_AUTO);
		initListener();
	}

	/**
	 * 判断是否是滑动状态
	 * @return
	 */
	public boolean isScroll() {
		return mIsScroll;
	}
	
	/**
	 * 添加数据
	 * @param recordType
	 */
	public void addDatas(ArrayList<RecordType> mRecordTypes){
		itemList.clear();
		for (int i = 0; i < mRecordTypes.size(); i++) {
			itemList.addAll(mRecordTypes.get(i).getItemList());
		}
		mAdapter.addDatas(itemList);
		mAdapter.notifyDataSetChanged();
	}
	
	/**
	 * 获取被选择的位置
	 * @return
	 */
	public int getSelectedPosition(){
		return mSelectedPosition;
	}
	
	/**
	 * 滚动到某个类型的第一个
	 */
	public void scrollToSelectType(RecordType recordType){
		if(recordType.getRecordType() == getSelectedItem().getRecordType())return;
		if (getSelectedItem().getRecordType() == recordType.getRecordType()) {
			return;
		}
		int position = itemList.indexOf(recordType.getItem(0));
		mCardView.setSelection(position,true);
	}
	
	/**
	 * 获取选中的RecordItemSamp
	 * @return
	 */
	public RecordItemSamp getSelectedItem(){
		return (RecordItemSamp) mAdapter.getItem(mSelectedPosition);
	}
	
	public void initListener(){
		 mCardView.setOnItemSelectedListener(new OnItemSelectedListener() {
			 //获取选中页的事件
				@Override
				public void onItemSelected(AdapterView<?> parent, View view,
						int position, long id) {
					mSelectedPosition = position;
					mIsScroll = true;
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
				RecordItemSamp itemSamp = (RecordItemSamp) mAdapter.getItem(position);
				if (onCardItemClickListener != null) {
					onCardItemClickListener.onItemClick(position, itemSamp);
				}
			}
		});
	}
	
	public interface OnCardItemSelectedListener{
		public void onItemSelected(RecordItemSamp itemSamp);
	}
	
	private OnCardItemSelectedListener cardItemSelected;
	
	/**
	 * 设置滑动停止时，获取选中页的类型的回调
	 * @param cardItemSelected
	 */
	public void setItemSelectedListener(OnCardItemSelectedListener cardItemSelected){
		this.cardItemSelected = cardItemSelected;
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
			mIsScroll = false;
			if (cardItemSelected != null) {
				RecordItemSamp itemSamp = (RecordItemSamp) mAdapter.getItem(mSelectedPosition);
				cardItemSelected.onItemSelected(itemSamp);
			}
		}
	};
	
	/**
	 * Item点击事件
	 */
	public void setCardItemClickListener(OnCardItemClickListener onCardItemClickListener){
		this.onCardItemClickListener = onCardItemClickListener;
	}
	public interface OnCardItemClickListener{
		public void onItemClick(int position , RecordItemSamp itemSamp);
	}
	private OnCardItemClickListener onCardItemClickListener;
	/**
	 * 删除
	 * @param position
	 */
	public void delItem(final DelItemCallBack onDelItemCallBack){
//		this.onDelItemCallBack = onDelItemCallBack;
		final CustomDialog dialog = new CustomDialog(getContext());
		View delView = LayoutInflater.from(getContext()).inflate(R.layout.view_delete_item, null);
		dialog.setOnlyContainer(delView);
		dialog.setCanceledOnTouchOutside(false);
		Button btnSure = (Button) delView.findViewById(R.id.btn_delete_item_sure);
		Button btnCancel = (Button) delView.findViewById(R.id.btn_delete_item_cancel);
		
		btnCancel.setOnClickListener(new OnClickListener() {
			//取消删除
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		
		btnSure.setOnClickListener(new OnClickListener() {
			//确认删除
			public void onClick(View v) {
				mDelItemSamp = (RecordItemSamp) mAdapter.getItem(mCardView.getSelectedItemPosition());
				dialog.dismiss();
				if (mDelItemSamp.getRecStatus() == RecordItemSamp.REC_UPLOAD) {
					onDelItemCallBack.onDeleteItem(mDelItemSamp, true);
					return;
				}
				
				mProgressDialog = new CustomProgressDialog(getContext());
				mProgressDialog.setMessage("正在删除…");
				if (mRemoveLogic == null) {
					mRemoveLogic = new RemoveRecordItemLogic(new RemoveItemCallBack() {
						public void doRemoveback(int recordItemId, boolean isSuccess) {
							if(mProgressDialog != null){
								mProgressDialog.dismiss();
								mProgressDialog = null;
							}
							if (isSuccess) {
								//删除成功后控件的移除动画
								/*mRemoveViewHandler.post(new Runnable() {
									public void run() {
										View bb = mCardView.getSelectedView();
										Animation mAnimation = AnimationUtils.loadAnimation(getContext(), R.anim.popupwindow_down_exit);
										mAnimation.setDuration(300);
										mAnimation.setFillAfter(true);
										bb.setVisibility(View.GONE);
										bb.startAnimation(mAnimation);
										
										//删除动画完成后回调逻辑
										mAnimation.setAnimationListener(new AnimationListener() {
											public void onAnimationStart(Animation animation) {}
											public void onAnimationRepeat(Animation animation) {}
											public void onAnimationEnd(Animation animation) {
												onDelItemCallBack.onDeleteItem(mDelItemSamp, true);
											}
										});
									}
								});*/
								onDelItemCallBack.onDeleteItem(mDelItemSamp,true);
							}else{
								UITools.showToast("删除失败");
							}
						}
					});
				}
				mRemoveLogic.removeRecordItem(mDelItemSamp.getRecordItemId());
			}
		});
	}
	
	/**
	 * 删除病历记录的回调
	 */
	public interface DelItemCallBack{
		public void onDeleteItem(RecordItemSamp itemSamp, boolean isDelSuccess);
	}
	
//	private DelItemCallBack onDelItemCallBack;
}
