package com.fq.halcyon;

import com.fq.http.async.uploadloop.FQLooper;

public class HalcyonUploadLooper extends FQLooper{

	private static HalcyonUploadLooper instance;
	private HalcyonUploadLooper() {
	}
	
	public static HalcyonUploadLooper getInstance(){
		if (instance == null) {
			instance = new HalcyonUploadLooper();
		}
		return instance;
	};
	
}
