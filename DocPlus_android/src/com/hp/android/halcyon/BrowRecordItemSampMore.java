package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.halcyon.logic2.RemoveRecordItemLogic;
import com.fq.halcyon.logic2.RemoveRecordItemLogic.RemoveItemCallBack;
import com.fq.lib.record.RecordConstants;
import com.hp.android.halcyon.widgets.ClickGridView;
import com.hp.android.halcyon.widgets.ClickGridView.OnTouchBlankPositionListener;

public class BrowRecordItemSampMore extends BaseActivity implements OnItemClickListener, OnItemLongClickListener, RemoveItemCallBack{

	public static final int RESULT_CODE = 121;
	
	private int mState;
	private ClickGridView mGridView;
	private RecordType mRecordItemType;
	private ArrayList<RecordItemSamp> mRecordSamps;
	private RecordSampAdapter mAdapter;

	private RemoveRecordItemLogic mRemoveLogic;
	
	@Override
	public int getContentId() {
		return R.layout.activity_brow_record_item_samp_more;
	}

	@Override
	public void init() {
//		mRecordItemType = (RecordType) getIntent().getSerializableExtra("recordItemType");
		int id = getIntent().getIntExtra("recordItemTypeId", 0);
		mRecordItemType = BrowRecordActivity.getRecordTypes().get(id);
		mRecordSamps = mRecordItemType.getItemList();
		
		setTitle(RecordConstants.getTypeNameByRecordType(mRecordItemType.getRecordType()));
		
		mGridView = (ClickGridView) findViewById(R.id.gv_brow_record_samp_more);
		mAdapter = new RecordSampAdapter();
		mGridView.setAdapter(mAdapter);
		
		mGridView.setOnItemClickListener(this);
		mGridView.setOnItemLongClickListener(this);
		mGridView.setOnTouchBlankPositionListener(new OnTouchBlankPositionListener() {
			public boolean onTouchBlankPosition() {
				if(mState == BrowRecordActivity.STATE_DEL){
					mState = BrowRecordActivity.STATE_NORMAL;
					mAdapter.notifyDataSetChanged();
				}
				return true;
			}
		});
	}
	
	/**
	 * 一个病历记录子项被点击
	 */
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		if(mState == BrowRecordActivity.STATE_DEL){
			deleteRecordItem(position);
			return;
		}
		RecordItemSamp item = mRecordSamps.get(position);
		BrowRecordActivity.onSampClick(this, item);
	}

	/**
	 * 删除一个病历记录
	 * @param position 这个病历记录在它所在病历中的索引值
	 */
	private void deleteRecordItem(int position){
		RecordItemSamp samp = mRecordSamps.get(position);
		mRecordSamps.remove(position);
		mAdapter.notifyDataSetChanged();

		if(mRemoveLogic == null)mRemoveLogic = new RemoveRecordItemLogic(this);
		mRemoveLogic.removeRecordItem(samp.getRecordItemId());
	}
	
	/**
	 * 长按病历记录（简洁）时调用
	 */
	@Override
	public boolean onItemLongClick(AdapterView<?> parent, View view,int position, long id) {
		if(mState == BrowRecordActivity.STATE_DEL)return true;
		mState = BrowRecordActivity.STATE_DEL;
		mAdapter.notifyDataSetChanged();
		return true;
	}
	
	@Override
	public void onBackPressed() {
		if(mState == BrowRecordActivity.STATE_DEL){
			mState = BrowRecordActivity.STATE_NORMAL;
			mAdapter.notifyDataSetChanged();
			return;
		}
		Intent intent = new Intent();
//		intent.putExtra("record_types", mRecordItemType);
		setResult(RESULT_CODE,intent);
		finish();
	}
	
	public class RecordSampAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mRecordSamps.size();
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			RecordItemSamp samp = mRecordSamps.get(position);
			if(convertView == null){
				convertView = LayoutInflater.from(BrowRecordItemSampMore.this).inflate(R.layout.item_record_item_layout, null);
			}
			convertView.findViewById(R.id.iv_brow_photo).setVisibility(View.GONE);
			FrameLayout container = (FrameLayout) convertView.findViewById(R.id.fl_brow_record_item_container);
			View view = container.findViewById(99);
			if(view != null)container.removeView(view);
			
			if(samp.getRecStatus() == RecordItemSamp.REC_SUCC){//识别完成
				view = LayoutInflater.from(BrowRecordItemSampMore.this).inflate(R.layout.item_brow_record_type_item_recyes, null);
				view.setId(99);
				container.addView(view);
				String time = "".equals(samp.getUploadTime())?"":samp.getUploadTime().substring(0, 8); 
				((TextView)view.findViewById(R.id.tv_record_item_date)).setText(samp.getInfoAbstract());
				((TextView)view.findViewById(R.id.tv_record_item_recstate)).setText(time);
				((TextView)view.findViewById(R.id.tv_recort_item_photo_number)).setText(RecordConstants.getAbstractByType(samp.getRecordType()));
			}else{//无法识别或识别中（上传阶段）
				view = LayoutInflater.from(BrowRecordItemSampMore.this).inflate(R.layout.item_brow_record_type_item_recno, null);
				view.setId(99);
				container.addView(view);
				((TextView)view.findViewById(R.id.tv_recort_item_photo_number)).setText("图片"+samp.getImageCount()+"张");
				((TextView)view.findViewById(R.id.tv_record_item_date)).setText(samp.getUploadTime());
				TextView textView = (TextView) view.findViewById(R.id.tv_record_item_recstate);
				if(samp.getRecStatus() == RecordItemSamp.REC_FAIL){
					textView.setText("无法识别");
					textView.setTextColor(0xffeb6001);
				}else{
					textView.setText("识别中...");
					textView.setTextColor(0xffdcdedd);
				}
			}
			
			View delView = convertView.findViewById(R.id.fl_brow_record_delete);
			delView.setVisibility(mState==BrowRecordActivity.STATE_DEL?View.VISIBLE:View.GONE);
//			delView.setOnClickListener(this);
			
			return convertView;
		}
	}

	@Override
	public void doRemoveback(int recordItemId, boolean isSuccess) {
		
	}
}
