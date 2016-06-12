package com.hp.android.halcyon.adapter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;

public class RecordTitleAdapter extends BaseAdapter{

	private Context mContext;
	private List<String> mTitleList = new ArrayList<String>();
	private int selectedPosition = 0; //被选中的位置
	
	public RecordTitleAdapter(Context mContext) {
		this.mContext = mContext;
	}
	
	public void setMap(HashMap<String, Object> map){
		if(map == null)return;
		mTitleList.clear();
		Set<String> keys =  map.keySet();
		Iterator<String> it = keys.iterator();
		while(it.hasNext()){
			String key = it.next();
			mTitleList.add(key);
		
		}
		notifyDataSetChanged();
	}
	
	public void setSelectedPosition(int selectedPosition) {
		this.selectedPosition = selectedPosition;
	}
	
	public void addList(List<String> mTitleList) {
		this.mTitleList.clear();
		this.mTitleList = mTitleList;
		notifyDataSetChanged();
	}
	
	@Override
	public int getCount() {
		return mTitleList.size();
	}

	@Override
	public String getItem(int position) {
		return mTitleList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View view, ViewGroup group) {
		if(view == null){
			view = LayoutInflater.from(mContext).inflate(R.layout.item_record_title, null);
		}
		TextView mTextTitle = (TextView) view.findViewById(R.id.tv_item_record_title);
		FrameLayout mBgLayout = (FrameLayout) view.findViewById(R.id.fl_item_record_bg);
		mBgLayout.setSelected(false);
		if(position == selectedPosition){
			mBgLayout.setSelected(true);
		}
		mTextTitle.setText(getItem(position));
		return view;
	}

}
