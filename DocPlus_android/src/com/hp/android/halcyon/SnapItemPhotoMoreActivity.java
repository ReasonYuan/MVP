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
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneType;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.SnapPhotoManager;
import com.hp.android.halcyon.AllRecordPhotoActivity.STATE;
import com.hp.android.halcyon.widgets.ClickGridView;
import com.hp.android.halcyon.widgets.ClickGridView.OnTouchBlankPositionListener;

public class SnapItemPhotoMoreActivity extends BaseActivity implements OnItemClickListener, OnItemLongClickListener{

	private STATE mState;
	private ClickGridView mGridView;
	private RecordSampAdapter mAdapter;
	private ArrayList<PhotoRecord> mPhotos;
	
	private OneType mType;
	
	@Override
	public int getContentId() {
		return R.layout.activity_brow_record_item_samp_more;
	}

	@Override
	public void init() {
		SnapPhotoManager snap = SnapPhotoManager.getInstance();
		
		int index = getIntent().getIntExtra("snap_item_index", -1);
		if(index != -1)mType = snap.getTypeByIndex(index);
		if(mType != null){
			setTitle(RecordConstants.getTypeNameByRecordType(mType.getType()));
			
			mPhotos = mType.getCopyById(0).getPhotos();
			mGridView = (ClickGridView) findViewById(R.id.gv_brow_record_samp_more);
			mAdapter = new RecordSampAdapter();
			mGridView.setAdapter(mAdapter);
			
			mGridView.setOnItemClickListener(this);
			mGridView.setOnItemLongClickListener(this);
			mGridView.setOnTouchBlankPositionListener(new OnTouchBlankPositionListener() {
				public boolean onTouchBlankPosition() {
					if(mState == STATE.DEL){
						mState = STATE.NORMAL;
						mAdapter.notifyDataSetChanged();
					}
					return true;
				}
			});
		}
	}

	
	/**
	 * 一个病历记录子项被点击
	 */
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		if(mState == STATE.DEL){
			deleteRecordPhoto(position);
		} else {
			Intent intent = new Intent(this,BrowImageActivity.class);
			intent.putExtra("photo_array", mType.getAllPhotos());
			intent.putExtra("image_title", RecordConstants.getTypeNameByRecordType(mType.getType()));
			startActivity(intent);
		}
	}

	/**
	 * 删除一份病历的一张图片
	 * @param type 一个病历
	 * @param index 要删除图片的序号
	 */
	private void deleteRecordPhoto(int index) {
		mPhotos.remove(index);
		if(mPhotos.size() > 0){
			mAdapter.notifyDataSetChanged();
		}else{
			SnapPhotoManager.getInstance().getTypes().remove(mType);
			mGridView.setVisibility(View.INVISIBLE);
		}
	}
	
	/**
	 * 长按病历记录（简洁）时调用
	 */
	@Override
	public boolean onItemLongClick(AdapterView<?> parent, View view,int position, long id) {
		if(mState == STATE.DEL)return true;
		mState = STATE.DEL;
		mAdapter.notifyDataSetChanged();
		return true;
	}
	
	@Override
	public void onTopLeftBtnClick(View view) {
		finish();
	}
	
	@Override
	public void onBackPressed() {
		if(mState == STATE.DEL){
			mState = STATE.NORMAL;
			mAdapter.notifyDataSetChanged();
			return;
		}
		super.onBackPressed();
	}
	
	public class RecordSampAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mPhotos.size();
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
			if(convertView == null){
				convertView = LayoutInflater.from(SnapItemPhotoMoreActivity.this).inflate(R.layout.item_record_snap_photo_view, null);
			}
			
			TextView tv = (TextView) convertView.findViewById(R.id.tv_snap_record_type);
			tv.setVisibility(View.VISIBLE);
			tv.setText(RecordConstants.getTypeTitleByRecordType(mType.getType()));
			
			convertView.findViewById(R.id.iv_brow_photo).setVisibility(View.GONE);

			View state = convertView.findViewById(R.id.fl_brow_record_delete);
			state.setVisibility(mState == STATE.DEL?View.VISIBLE:View.GONE);
			
			return convertView;
		}
	}
}
