package com.fq.android.plus.recorditem.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.RecordItem.EXAM_STATE;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.util.UITools;

public class ExaminationView implements IRecordItemView{

	private ListView mItemList;
	private Context mContext;
	private View mView;
	private CommonAdapter<RecordItem.RecordExamItem> mAdapter;
	
	public ExaminationView(Context context) {
		mContext = context;
		mView = LayoutInflater.from(context).inflate(R.layout.view_record_item_examination, null);
		initView();
	}

	@Override
	public View getRecordItemView() {
		return mView;
	}
		
	private void initView(){
		mItemList = (ListView) mView.findViewById(R.id.record_item_examination_list);
		mItemList.setAdapter(mAdapter = new CommonAdapter<RecordItem.RecordExamItem>(mContext,R.layout.item_record_assay) {
			@Override
			public void convert(int position, ViewHolder helper,final RecordItem.RecordExamItem item) {
				TextView name = helper.getView(R.id.tv_item_record_assay_name);
				TextView result = helper.getView(R.id.tv_item_record_assay_result);
				TextView expect = helper.getView(R.id.tv_item_record_assay_refvalue);
				TextView unit = helper.getView(R.id.tv_item_record_assay_unit);
				
				name.setText(item.name);
				expect.setText(item.expectValue);
				unit.setText(item.unit);
				
				result.setText(item.examValus+" "+item.getValueState());
				
				if(item.getExamState() == EXAM_STATE.M){
					int color = mView.getResources().getColor(R.color.examination_normal);
					name.setTextColor(color);
					result.setTextColor(color);
					expect.setTextColor(color);
					unit.setTextColor(color);
				}else{
					int color = mView.getResources().getColor(R.color.examination_unnormal);
					name.setTextColor(color);
					result.setTextColor(color);
					expect.setTextColor(color);
					unit.setTextColor(color);
				}
				
				name.setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						UITools.showToast(item.name);
					}
				});
			}
		});
	}

	@Override
	public void setDatas(RecordItem recordItem) {
		mAdapter.addDatas(recordItem.getExams());
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
