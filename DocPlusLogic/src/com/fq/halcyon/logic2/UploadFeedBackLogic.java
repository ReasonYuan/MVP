package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class UploadFeedBackLogic {

	public  interface UploadFeedBackLogicInterface extends FQHttpResponseInterface{
		public void onDaraReturn(int responseCode, String msg);
		public void onErrorReturn(int code, Throwable e);
	}
	
	@Weak
	private UploadFeedBackLogicInterface mInterface;
	
	private class UploadFeedBackLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onErrorReturn(code,e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				mInterface.onDaraReturn(responseCode,msg);
			}else{
				mInterface.onErrorReturn(responseCode,new Throwable());
			}
		}
		
	}
	
	private UploadFeedBackLogicHandle mHandle = new UploadFeedBackLogicHandle();
	
	public UploadFeedBackLogic(UploadFeedBackLogicInterface mIn,String feedInfo) {
		mInterface  = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("feed_info", feedInfo);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/add_feed.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}

}
