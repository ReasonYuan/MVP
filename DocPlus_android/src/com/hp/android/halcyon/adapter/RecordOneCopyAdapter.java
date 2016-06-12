package com.hp.android.halcyon.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.lib.record.RecordConstants;
import com.hp.android.halcyon.BrowRecordActivity;

/**
 * 浏览病历界面，每一种类型的病历里面会有多个病历记录（简介）以及一个add按钮（入院、出院除外）<br/>
 * 每一种病历类型会有一个GridView显示它里面的病历记录，这个adapter用于适配这些GridView
 * @author reason
 *
 */
public class RecordOneCopyAdapter extends BaseAdapter{
	/**
	 * 最多显示的病历记录（简介）的数量，这里是3个，第4个是[+]按钮
	 */
	public static final int SHOW_NUM = 3;
	
	private Context mContext;
//	private RecordItemType mRecordItemType;
	private ArrayList<RecordItemSamp> mitemSamps;
	private int mCount;
	private int mType;
	
	private int mState;
	
	public RecordOneCopyAdapter(Context context,RecordType item){
		mContext = context;
//		mRecordItemType = item;
		mType = item.getRecordType();
		mitemSamps = item.getItemList();
		
		updateCount();
	}

	/**
	 * 更新item的总量
	 */
	public void updateCount(){
		mCount = mitemSamps.size();
		mCount = mCount > SHOW_NUM?4:mCount+1;
	}
	
	public void notifyDataSetChanged(){
		updateCount();
		super.notifyDataSetChanged();
	}
	
	public void setState(int state){
		mState = state;
	}
	
	@Override
	public int getCount() {
		return mCount;
	}

	@Override
	public RecordItemSamp getItem(int position) {
		return mitemSamps.get(position);
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if(convertView == null){
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_record_item_layout, null);
		}
		
		if(position == mCount - 1){
			convertView.findViewById(R.id.iv_brow_photo).setVisibility(View.VISIBLE);
			convertView.findViewById(R.id.fl_brow_record_item_container).setVisibility(View.GONE);
			convertView.findViewById(R.id.fl_brow_record_delete).setVisibility(View.GONE);
			if(mType == RecordConstants.TYPE_ADMISSION || mType == RecordConstants.TYPE_DISCHARGE){
				if(mCount>1)convertView.setVisibility(View.GONE);
			}
		}else{
			FrameLayout container = (FrameLayout) convertView.findViewById(R.id.fl_brow_record_item_container);
			View delView = convertView.findViewById(R.id.fl_brow_record_delete);
			convertView.findViewById(R.id.iv_brow_photo).setVisibility(View.GONE);
			container.setVisibility(View.VISIBLE);
			delView.setVisibility(mState==BrowRecordActivity.STATE_DEL?View.VISIBLE:View.GONE);
			
			RecordItemSamp copy = getItem(position);
//			convertView.setTag(copy);
			
			View view = container.findViewById(99);
			if(view != null)container.removeView(view);
			if(copy.getRecStatus() == RecordItemSamp.REC_SUCC){//识别完成
				view = LayoutInflater.from(mContext).inflate(R.layout.item_brow_record_type_item_recyes, null);
				view.setId(99);
				container.addView(view);
				String time = "".equals(copy.getUploadTime())?"":copy.getUploadTime().substring(0, 8);
				((TextView)view.findViewById(R.id.tv_record_item_date)).setText(copy.getInfoAbstract());
				((TextView)view.findViewById(R.id.tv_record_item_recstate)).setText(time);
				((TextView)view.findViewById(R.id.tv_recort_item_photo_number)).setText(RecordConstants.getAbstractByType(copy.getRecordType()));
			}else{//无法识别或识别中
				view = LayoutInflater.from(mContext).inflate(R.layout.item_brow_record_type_item_recno, null);
				view.setId(99);
				container.addView(view);
				((TextView)view.findViewById(R.id.tv_recort_item_photo_number)).setText("图片"+copy.getImageCount()+"张");
				((TextView)view.findViewById(R.id.tv_record_item_date)).setText(copy.getUploadTime());
				TextView textView = (TextView) view.findViewById(R.id.tv_record_item_recstate);
				if(copy.getRecStatus() == RecordItemSamp.REC_FAIL){
					textView.setText("无法识别");
					textView.setTextColor(0xffeb6001);
				}else{
					textView.setText("识别中...");
					textView.setTextColor(0xffdcdedd);
				}
			}
		}
		
		 return convertView; 
	}
}
