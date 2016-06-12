package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class ViewOCRInfoLogic {

	public interface ViewOCRInfoLogicCallBack{
		public void getOCRInfoSuccess(int imageId,String imageTxt, String correctPercent);
		public void getOCRInfoError(String error);
	}
	@Weak
	private ViewOCRInfoLogicCallBack onCallBack;
	
	private int imageId = 0;
	
	public ViewOCRInfoLogic(ViewOCRInfoLogicCallBack onCallBack){
		this.onCallBack = onCallBack;
	}
	
	public void viewOCRInfo(int imageId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		this.imageId = imageId;
		map.put("image_id", imageId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/image/view_txt.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, new ViewOCRInfoLogicHandle());
	}
	
	class ViewOCRInfoLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.getOCRInfoError(e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			
			if(responseCode == 0){
				JSONObject obj = (JSONObject) results;
				double percent = obj.optDouble("correct_percent");
				onCallBack.getOCRInfoSuccess(imageId,obj.optString("image_txt"),String.format("%.1f", percent*100l)+"%");
			}else{
				onCallBack.getOCRInfoError(msg);
			}
		}
	}
}
