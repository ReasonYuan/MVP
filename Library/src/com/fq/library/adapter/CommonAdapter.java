package com.fq.library.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

public abstract class CommonAdapter<T> extends BaseAdapter {

	protected LayoutInflater mInflater;
	protected Context mContext;
	protected List<T> mDatas;
	protected final int mItemLayoutId;
	
	public CommonAdapter(Context context, int itemLayoutId) {
		mInflater = LayoutInflater.from(context);
		this.mContext = context;
		this.mDatas = new ArrayList<T>();
		this.mItemLayoutId = itemLayoutId;
	}
	
	public CommonAdapter(Context context, List<T> mDatas, int itemLayoutId) {
		mInflater = LayoutInflater.from(context);
		this.mContext = context;
		this.mDatas = new ArrayList<T>();
		mDatas.addAll(mDatas);
		this.mItemLayoutId = itemLayoutId;
	}
	
	public void addDatas(List<T> datas){
		mDatas = datas;
		notifyDataSetChanged();
	}
	
	public void cleanDatas(){
		this.mDatas.clear();
	}
	
	@Override
	public int getCount() {
		return mDatas.size();
	}
	
	@Override
	public T getItem(int position) {
		return mDatas.get(position);
	}
	
	@Override
	public long getItemId(int position) {
		return position;
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		final ViewHolder viewHolder = getViewHolder(position, convertView, parent);
		convert(position,viewHolder, getItem(position));
		return viewHolder.getConvertView();
	}
	
	private ViewHolder getViewHolder(int position, View convertView, ViewGroup parent){
		return ViewHolder.getInstances(mContext, convertView, parent, mItemLayoutId, position);
	}
	
	public abstract void convert(int position, ViewHolder helper, T object);
	
}
