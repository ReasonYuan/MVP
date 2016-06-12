package com.hp.android.halcyon.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.record.RecordConstants;

public class SnapPicGrlleryAdapter extends BaseAdapter{

	private Context mContext;
	
	private int[] TYPE_IDS;
	
	public SnapPicGrlleryAdapter(Context mContext,int[] ids) {
		this.mContext = mContext;
		TYPE_IDS = ids;
	}
	
	@Override
	public int getCount() {
		return Integer.MAX_VALUE;
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View view, ViewGroup group) {
		if(view == null){
			view = LayoutInflater.from(mContext).inflate(R.layout.item_snap_pic_grllery, null);
		}
		final TextView mType = (TextView) view.findViewById(R.id.item_snap_pic_type);
		View mLine = view.findViewById(R.id.item_snap_pic_line);
		int uiIndex = position % TYPE_IDS.length;
		mType.setText(RecordConstants.getTypeTitleByRecordType(TYPE_IDS[uiIndex]));
		view.setTag(mLine);
		return view;
	}

}
