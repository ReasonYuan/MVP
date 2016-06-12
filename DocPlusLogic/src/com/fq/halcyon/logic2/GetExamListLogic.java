package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Exam;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class GetExamListLogic {

	private ArrayList<Exam> examList;
	public GetExamListCallBack onCallBack;
	public GetExamListHandle mHandle;
	
	public interface GetExamListCallBack{
		public void onGetExamListError(int code, String msg);
		public void onGetExamListResult(ArrayList<Exam> examList);
	};
	
	public GetExamListLogic(final GetExamListCallBack onCallBack) {
		this.onCallBack = onCallBack;
		examList = new ArrayList<Exam>();
		mHandle = new GetExamListHandle();
	}
	
	public void getExamList(int hosId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("hospital_id", hosId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/medicine/get_items_of_hospital.do";
		
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	public void getExamList(int hosId,String keywords){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("hospital_id", hosId);
		map.put("key_words", keywords);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/medicine/get_items_of_hospital.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	class GetExamListHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onGetExamListError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0 && type == 2){
				JSONArray jsonArr = (JSONArray) results;
				int count = jsonArr.length();
				examList.clear();
				for (int i = 0; i < count; i++) {
					try {
						JSONObject obj = jsonArr.getJSONObject(i);
						Exam exam = new Exam();
						exam.setAtttributeByjson(obj);
						examList.add(exam);
						onCallBack.onGetExamListResult(examList);
					} catch (JSONException e) {
						onCallBack.onGetExamListError(responseCode, e.getMessage());
					}
				}
				
			}else{
				onCallBack.onGetExamListError(responseCode, msg);
			}
		}
		
	}
}
