package com.fq.android.plus.recorditem.view;

import android.content.Context;
import android.view.View;

import com.fq.halcyon.entity.RecordItem;
import com.fq.library.CustomView.HorScollView.PageView;

public class OtherExaminationView implements IRecordItemView{

	private Context mContext;
	private PageView mView;
	
	public OtherExaminationView(Context context) {
		mContext = context;
		initView();
	}

	@Override
	public View getRecordItemView() {
		return mView;
	}
		
	private void initView(){
		mView = new PageView(mContext);
	}

	@Override
	public void setDatas(RecordItem recordItem) {
		mView.initData(recordItem.getOtherExams());
	}


	@Override
	public boolean isEdit() {
		return false;
	}

	@Override
	public void exitEdit() {
		
	}

	@Override
	public void cancelEdit() {
	}

	@Override
	public void saveEdit() {
	}

	@Override
	public void setEditState(boolean state) {
	}

	@Override
	public void OnJoinEditListener(JoinEditStateCallBack editStateCallBack) {
	}
}
