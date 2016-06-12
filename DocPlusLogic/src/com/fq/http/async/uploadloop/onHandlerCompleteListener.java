package com.fq.http.async.uploadloop;

public interface onHandlerCompleteListener {
	/**
	 * 处理完成后的回调
	 * 
	 */
	public void onHandlerComplete(LoopCellHandle cell,int type, Object results);
}
