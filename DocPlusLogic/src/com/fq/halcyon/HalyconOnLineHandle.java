package com.fq.halcyon;

public abstract class HalyconOnLineHandle extends HalcyonHttpResponseHandle {

	/**
	 * 修改成功，保存更改数据到本地
	 * @param success 服务器是否修改成功
	 */
	public abstract void saveData(boolean success);
	
}
