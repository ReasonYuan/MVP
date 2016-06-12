package com.hp.android.halcyon.adapter;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.lib.record.RecordConstants;
import com.fq.library.cardview.FancyCoverFlow;
import com.fq.library.cardview.FancyCoverFlowAdapter;
import com.fq.library.utils.ScreenUtils;

@SuppressLint("NewApi")
public class RecordItemCardAdapter extends FancyCoverFlowAdapter{

	private ArrayList<RecordItemSamp> itemList;
	private Context context;
 	
	public RecordItemCardAdapter(Context context) {
		itemList = new ArrayList<RecordItemSamp>();
		this.context = context;
	}
	
	public void addDatas(ArrayList<RecordItemSamp> itemList){
		this.itemList = itemList;
	}
	
	@Override
	public int getCount() {
		return itemList.size();
	}

	@Override
	public Object getItem(int position) {
		return itemList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getCoverFlowItem(int position, View reusableView,
			ViewGroup parent) {
		View view = null;
		ViewHolder viewHolder = null;
		if (reusableView != null) {
			view = reusableView;
			viewHolder = (ViewHolder) view.getTag();
		}else{
			viewHolder = new ViewHolder();
			int viewWidth = ScreenUtils.getScreenWidth(context)/4*3;
			int viewHeight = ScreenUtils.getScreenHeight(context)/2;
			view = LayoutInflater.from(context).inflate(R.layout.view_record_card, parent, false);
			view.setLayoutParams(new FancyCoverFlow.LayoutParams(viewWidth , viewHeight));
			viewHolder.recordType = (TextView) view.findViewById(R.id.tv_record_card_type);
			viewHolder.content = (TextView) view.findViewById(R.id.tv_record_card_content);
			viewHolder.recordTitle = (TextView) view.findViewById(R.id.tv_mark);
			viewHolder.recordTime = (TextView) view.findViewById(R.id.tv_record_card_time);
			viewHolder.noItem = (TextView) view.findViewById(R.id.tv_record_card_none_item);
			viewHolder.recStatus = (TextView) view.findViewById(R.id.tv_record_card_status);
			viewHolder.recStatusLayout = (FrameLayout) view.findViewById(R.id.fl_record_card_status);
			view.setTag(viewHolder);
		}
		RecordItemSamp itemSamp = itemList.get(position);
		String typeStr = RecordConstants.getTypeTitleByRecordType(itemSamp.getRecordType());
		

		if (RecordItemSamp.REC_NONE_DATA == itemSamp.getRecStatus()) {
			viewHolder.recordType.setVisibility(View.GONE);
			viewHolder.content.setVisibility(View.GONE);
			viewHolder.recordTitle.setVisibility(View.GONE);
			viewHolder.recordTime.setVisibility(View.GONE);
			viewHolder.noItem.setVisibility(View.VISIBLE);
			viewHolder.recStatusLayout.setVisibility(View.GONE);
			viewHolder.noItem.setText("暂无"+ typeStr + "记录，请点击拍摄上传");
		}else{
			viewHolder.recordType.setVisibility(View.VISIBLE);
			viewHolder.content.setVisibility(View.VISIBLE);
			viewHolder.recordTitle.setVisibility(View.VISIBLE);
			viewHolder.recordTime.setVisibility(View.VISIBLE);
			viewHolder.noItem.setVisibility(View.GONE);
			if (itemSamp.getRecStatus() == RecordItemSamp.REC_ING || itemSamp.getRecStatus() == RecordItemSamp.REC_UPLOAD) {
				viewHolder.recStatusLayout.setVisibility(View.VISIBLE);
				viewHolder.recStatusLayout.setAlpha(0.5f);
				viewHolder.content.setVisibility(View.GONE);
				viewHolder.recordType.setVisibility(View.GONE);
				viewHolder.recStatus.setText("识别中…");
			}else if(itemSamp.getRecStatus() == RecordItemSamp.REC_FAIL){
				viewHolder.recStatusLayout.setAlpha(0.5f);
				viewHolder.recStatusLayout.setVisibility(View.VISIBLE);
				viewHolder.content.setVisibility(View.GONE);
				viewHolder.recordType.setVisibility(View.GONE);
				viewHolder.recStatus.setText("识别失败");
			}else{
				viewHolder.recStatusLayout.setVisibility(View.GONE);
				viewHolder.recordType.setText(typeStr + "记录");
				viewHolder.recordTime.setText("记录时间：" + itemSamp.getUploadTime());
			}
			
			viewHolder.recordTitle.setText(typeStr + "记录");
			viewHolder.content.setText(itemSamp.getInfoAbstract());
		}
		
		return view;
	}
	
	class ViewHolder{
		TextView recordType;
		TextView content;//摘要
		TextView recordTitle;
		TextView recordTime;
		TextView noItem;
		TextView recStatus;
		FrameLayout recStatusLayout;
	}
}
