package com.fq.http.potocol;

import com.fq.http.async.FQHeader;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQHttpResponseHandle.h"
]-*/
@ObjectiveCName("FQHttpResponseHandle")
public abstract class FQHttpResponseHandle {
	
	/**
	 * 处理异常，默认调用{@link #onError(int code,Throwable e)}
	 * @param code
	 * @param e
	 */
	public void handleError(int code,Throwable e) {
		onError(code, e);
	}
	
	/**
	 * 处理异常
	 * @param code 	异常代码
	 * @param e     
	 */
	public abstract void onError(int code,Throwable e);
	
	/**
	 * 处理服务器返回的数据
	 * @param data
	 */
	public abstract void handleResponse(byte[] data);
	
	/**
	 * 返回发起请求时应该设置的http headers
	 * @return
	 */
    public abstract  FQHeader[] getRequestHeaders();
    /**
     * 返回该请求的headers
     * @param headers
     */
    public abstract void setRequestHeaders(FQHeader[] headers);
}
