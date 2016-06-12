package com.fq.library.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

public class ViewHolder {

	private final SparseArray<View> mViews;
	private View mConvertView;
	
	private ViewHolder(Context context, ViewGroup parent, int layoutId, int position) {
		this.mViews = new SparseArray<View>();
		mConvertView = LayoutInflater.from(context).inflate(layoutId, parent, false);
		mConvertView.setTag(this);
	}
	
	 /** 
     * 拿到一个ViewHolder对象 
     * @param context 
     * @param convertView 
     * @param parent 
     * @param layoutId 
     * @param position 
     * @return 
     */ 
	public static ViewHolder getInstances(Context context, View convertView, ViewGroup parent, int layoutId, int position){
		if (convertView == null) {
			return new ViewHolder(context, parent, layoutId, position);
		}
		return (ViewHolder) convertView.getTag();
	}
	
	/** 
     * 通过控件的Id获取对于的控件，如果没有则加入views 
     * @param viewId 
     * @return 
     */
	public <T extends View> T getView(int viewId){
		View view = mViews.get(viewId);
		if (view == null) {
			view = mConvertView.findViewById(viewId);
			mViews.put(viewId, view);
		}
		
		return (T) view;
	}
	
	public View getConvertView(){
		return mConvertView;
	}
	
	/**
	 * 为TextView设置字符串
	 * @param viewId
	 * @param text
	 * @return
	 */
	public ViewHolder setText(int viewId, String text){
		TextView view = getView(viewId);
		view.setText(text);
		return this;
	}
	
	/**
	 * 为ImageView设置图片
	 * @param viewId
	 * @param 
	 */
	public ViewHolder setImageBitmap(int viewId, Bitmap bm){
		ImageView view = getView(viewId);
		view.setImageBitmap(bm);
		return this;
	}
	
	/**
	 * 通过Id设置图片
	 * @param viewId
	 * @param id
	 * @return
	 */
	public ViewHolder setImageBitmap(int viewId, int id){
		ImageView view = getView(viewId);
		view.setBackgroundResource(id);
		return this;
	}
}
