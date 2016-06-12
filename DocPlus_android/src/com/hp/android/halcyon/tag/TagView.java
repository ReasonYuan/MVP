package com.hp.android.halcyon.tag;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.fq.android.plus.R;

public abstract class TagView {

	protected View mView;
	protected Context mContext;
	
	/**
	 * @param mContext
	 */
	public TagView(Context mContext) {
		this.mContext = mContext;
		int viewId = getViewId();
		if(viewId == 0){
			mView = LayoutInflater.from(mContext).inflate(R.layout.view_tag, null);
		}else{
			mView = LayoutInflater.from(mContext).inflate(viewId, null);
		}
	}

	/**
	 * 设置View的布局文件
	 * @param layoutId  布局文件ID
	 */
	public abstract int getViewId();
	
	public View getView() {
		return mView;
	}

	/**
	 * 设置标签内容
	 * @param str  标签的显示内容
	 */
	public abstract void setTagText(String str, final TagStatusChangedListener statusChanged);
	
	/**
	 * 设置标签内容
	 * @param str  标签的显示内容
	 * @param colorType   奇数：显示green，偶数：显示pink
	 */
	public abstract void setTagText(String str,final int colorType, final TagStatusChangedListener statusChanged);
	
	
	/**将View从父控件中移除*/
	public void removeView(){
		if(getView().getParent() != null){
			((ViewGroup)getView().getParent()).removeView(getView());
		}
	}
	
	/**获取view的Tag*/
	public Object getTag(){
		return mView.getTag() == null ? "": mView.getTag();
	}
	
	/**设置标签的选中状态*/
	public void setSelected(boolean b){
		
	};
	
	/**通知外界标签的状态已经改变*/
	public interface TagStatusChangedListener{
		public void isChanged(boolean b);
		public void onClick(View view);
	}
	
	public TagStatusChangedListener statusChanged ;
}
