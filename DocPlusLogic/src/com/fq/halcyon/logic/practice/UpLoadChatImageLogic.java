package com.fq.halcyon.logic.practice;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.http.async.ParamsWrapper.FQProcessInterface;
import com.fq.lib.HttpHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class UpLoadChatImageLogic implements FQProcessInterface{
	public interface UpLoadChatImageCallBack{
		public void onUpLoadChatImageSuccess(int imageId);
		public void onUpLoadChatImageFailed(int errorCode,String msg);
		public void onProcess(float process);
	}
	
	@Weak
	public UpLoadChatImageCallBack mInterface;
	
	public void upLoadImage(UpLoadChatImageCallBack mIn,String path){
		mInterface = mIn;
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB + "/pub/upload_images.do", path, false,new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				if (mInterface != null) {
					mInterface.onUpLoadChatImageFailed(code, "上传失败"  + e.toString());
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (mInterface != null) {
					if(responseCode ==0 && type == 1){
						JSONObject json = (JSONObject)results;
						int imageId = json.optInt("image_id");
						if(imageId == 0){
							imageId = json.optInt("id");
						}
						mInterface.onUpLoadChatImageSuccess(imageId);
					}
				}
			}
		},this);
	}

	@Override
	public void setProcess(float process) {
		if (mInterface != null) {
			mInterface.onProcess(process);
		}
	}
}
