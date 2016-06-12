package com.fq.http.potocol;

import com.fq.http.async.ParamsWrapper;
import com.fq.lib.callback.ICallback;

public abstract class HttpClientPotocol {

	/*
	 * 默认超时，10s
	 */
	public static final int DEFAULT_TIME_OUT = 10;
	
	protected static HttpClientPotocol mInstance;

	public static HttpClientPotocol getInstance() {
		return mInstance;
	}
	
	/**
	 * 设置session过期后的回调
	 * @param callback
	 */
	public abstract void setOnSessionExpiredCallback(ICallback callback);
	
	public abstract ICallback getOnSessionExpiredCallback();
	
	public abstract HttpRequestPotocol sendPostRequest(String url, FQHttpResponseHandle responseHandle);

	public abstract HttpRequestPotocol sendGetRequest(String url, FQHttpResponseHandle responseHandle);

	public abstract HttpRequestPotocol sendPostRequest(String url, ParamsWrapper params, FQHttpResponseHandle responseHandle);

	public abstract HttpRequestPotocol sendGetRequest(String url, ParamsWrapper params, FQHttpResponseHandle responseHandle);

	public abstract HttpRequestPotocol sendPostRequest(String url, ParamsWrapper params, FQHttpResponseHandle responseHandle, int timeOut);

	public abstract HttpRequestPotocol sendGetRequest(String url, ParamsWrapper params, FQHttpResponseHandle responseHandle, int timeOut);

	public abstract String encode(String value);

	public abstract String decode(String value);
	
	public abstract void cancle(String paramsString);

}
