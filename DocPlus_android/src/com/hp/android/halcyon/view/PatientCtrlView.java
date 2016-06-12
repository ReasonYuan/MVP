package com.hp.android.halcyon.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.fq.android.plus.R;

public class PatientCtrlView extends FrameLayout implements OnClickListener{

		private LinearLayout mBtnShare;
		private LinearLayout mBtnReName;
		private LinearLayout mBtnDelete;
		private View mView;
		private Context mContext;
		private boolean mIsShow;
		private PatiantCtrlViewClickListener mListener;
	public PatientCtrlView(Context context) {
		super(context);
		mContext = context;
		init();
	}

	public PatientCtrlView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mContext = context;
		init();
	}


	public PatientCtrlView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
		init();
	}


	private void  init(){
		mView = LayoutInflater.from(mContext).inflate(R.layout.view_patient_contral, null);
		mBtnShare = (LinearLayout)mView.findViewById(R.id.btn_pc_share);
		mBtnReName =  (LinearLayout) mView.findViewById(R.id.btn_pc_rename);
		mBtnDelete =  (LinearLayout)mView.findViewById(R.id.btn_pc_delete);
		mBtnShare.setOnClickListener(this);
		mBtnReName.setOnClickListener(this);
		mBtnDelete.setOnClickListener(this);
		addView(mView);
		this.setVisibility(View.GONE);
	}

	@Override
	public void onClick(View v) {
		if (mListener != null) {
			switch (v.getId()) {
			case R.id.btn_pc_share:
				mListener.shareCallBack();
				break;
			case R.id.btn_pc_rename:
				mListener. renameCallBack();
				break;
			case R.id.btn_pc_delete:
				mListener. deleteCallBack();
				break;

			default:
				break;
			}
		}
	}
	
	public interface PatiantCtrlViewClickListener{
		public void shareCallBack();
		public void renameCallBack();
		public void deleteCallBack();
	}
	
	public void setPatiantCtrlViewClickListener(PatiantCtrlViewClickListener mListener){
		this.mListener = mListener;
	}
	
	public void show(){
		if (mIsShow) {
			return;
		}
		this.setVisibility(View.VISIBLE);
		Animation mAnimation = AnimationUtils.loadAnimation(mContext, R.anim.popupwindow_up_enter);
		mAnimation.setDuration(300);
		this.startAnimation(mAnimation);
		mIsShow = true;
	}
	
	public void hidden(){
		if (!mIsShow) {
			return;
		}
		Animation mAnimation = AnimationUtils.loadAnimation(mContext, R.anim.popupwindow_down_exit);
		mAnimation.setDuration(300);
		this.startAnimation(mAnimation);
		this.setVisibility(View.GONE);
		mIsShow = false;
	}
	
   public boolean getShowStatus(){
	   return mIsShow;
   }
   
   public void hintBtnShare(){
	   mBtnShare.setVisibility(View.GONE);
   }
   
   public void hintBtnDel(){
	   mBtnDelete.setVisibility(View.GONE);
   }
   
   public void hintBtnReName(){
	   mBtnReName.setVisibility(View.GONE);
   }
}
