package com.fq.android.plus.recorditem.view;

import android.view.View;

import com.fq.halcyon.entity.RecordItem;

public interface IRecordItemView {

	public View getRecordItemView();
	
	/**
	 * 设置数据
	 * @param recordItem
	 */
	public  void setDatas(RecordItem recordItem);
	
	/**
	 * 设置编辑状态
	 * @param state
	 */
	public void setEditState(boolean state);
	
	/**
	 * 获取编辑状态
	 * @return
	 */
	public boolean isEdit();
	
	/**
	 * 退出编辑状态
	 */
	public void exitEdit();
	
	/**
	 * 取消编辑
	 */
	public void cancelEdit();
	
	/**
	 * 保存编辑
	 */
	public void saveEdit();
	
	public interface JoinEditStateCallBack{
		public void joinEditState();
		public void showMuLuView();
	}
	
	public void OnJoinEditListener(JoinEditStateCallBack editStateCallBack);
}
