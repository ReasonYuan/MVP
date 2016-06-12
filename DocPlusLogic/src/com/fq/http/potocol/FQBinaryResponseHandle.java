package com.fq.http.potocol;

import com.fq.http.async.FQHeader;
import com.fq.http.async.ParamsWrapper;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQBinaryResponseHandle.h"
]-*/
@ObjectiveCName("FQBinaryResponseHandle")
public abstract class FQBinaryResponseHandle extends FQHttpResponseHandle {

	public ParamsWrapper mParams;
	
	private FQHeader[] mHeaders = null;
	
	@Override
	public void handleResponse(byte[] data) {
		 handleBinaryData(data);
	}
	
	public abstract void handleBinaryData(byte[] data);
	
	@Override
	public FQHeader[] getRequestHeaders() {
		return mHeaders;
	}
	
	@Override
	public void setRequestHeaders(FQHeader[] headers) {
		this.mHeaders = headers;
	}

	public ParamsWrapper getParams() {
		return mParams;
	}

	public void setParams(ParamsWrapper mParams) {
		this.mParams = mParams;
	}
}
