package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.HomeAge;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class HomeAgeLogic {

	public interface HomeAgeLogicCallBack {
		public void getHomeAgeSuccess(HomeAge homeAge);
		public void getHomeAgeError(int code, String e);
	}
	
	@Weak
	private HomeAgeLogicCallBack callBack; 
	private HomeAgeHandle mHandle = new HomeAgeHandle();
	
	public HomeAgeLogic(HomeAgeLogicCallBack callBack) {
		this.callBack = callBack;
	}
	
	/**
	 * 根据所有的病案id获取数据
	 * @param patientIdList
	 */
	public void getAgeLogic(ArrayList<Integer> patientIdList) {
		HashMap<String , Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		try {
			JSONArray mArray = new JSONArray(patientIdList);
			json.put("patient_ids", mArray);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String uri = UriConstants.Conn.URL_PUB + "/home/get_patient_age_count.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 获取所有的数据
	 */
	public void getAgeLogic() {
		HashMap<String , Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/home/get_patient_age_count.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class HomeAgeHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			callBack.getHomeAgeError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject json = (JSONObject) results;
				HomeAge homeAge = new HomeAge();
				homeAge.setAtttributeByjson(json);
				callBack.getHomeAgeSuccess(homeAge);
			}else{
				callBack.getHomeAgeError(responseCode, msg);
			}
		}
	}
}
