package com.fq.halcyon.logic;

public interface BaseLogic {
	
	/**
	 * @param type 一个界面有可能发送多个数据请求，更新ui时可以根据type进行区分
	 */
	public void updateUI(int type);
	
	public void onLogicError(int code,Throwable e);
}
