package com.fq.http.potocol;

import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQStringResponseHandle.h"
]-*/
@ObjectiveCName("FQStringResponseHandle")
public abstract class FQStringResponseHandle extends FQBinaryResponseHandle{

	@Override
	public void handleBinaryData(byte[] data) {
		handleString(new String(data));
	}
 
	public  abstract void handleString(String value);
	
}
