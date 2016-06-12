package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 浏览病历图片的逻辑
 */
public class BrowsePicLogic {

	private ArrayList<HashMap<String, Object>> picList = new ArrayList<HashMap<String, Object>>();
	
	/**
	 * @param recordId  -病历Id
	 */
	public BrowsePicLogic(int recordId, final BrowsePicCallBack onCallBack) {
		this.onCallBack = onCallBack;
		HashMap< String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", recordId);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/records/list_sugeny_pic.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public class BrowsePicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onErrorCallBack(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				try {
					JSONObject jsonObj = (JSONObject) results;
					JSONArray jsonArray = jsonObj.getJSONArray("contents");
					int count = jsonArray.length();
					for (int i = 0; i < count; i++) {
							JSONObject json = jsonArray.getJSONObject(i);
							HashMap<String, Object> map = new HashMap<String, Object>();
							map.put("image_id", json.optInt("image_id"));
							map.put("image_path", json.getString("image_path"));
							picList.add(map);
						
					}
				} catch (JSONException e) {
						e.printStackTrace();
						onCallBack.onErrorCallBack(responseCode, msg);
				}
				
				onCallBack.onResultCallBack(picList);
			}else{
				onCallBack.onErrorCallBack(responseCode, msg);
			}
		}
		
	}
	
	public interface BrowsePicCallBack{
		
		public void onErrorCallBack(int code ,String msg);
		public void onResultCallBack(ArrayList<HashMap<String, Object>> picList);
	}
	
	@Weak
	public BrowsePicCallBack onCallBack;
	
	public BrowsePicHandle mHandle = new BrowsePicHandle();
}
