package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetPatientDiagnoseLogic {
	public interface GetPatientDiagnoseInterface {
		public void OnGetSuccess(int responseCode,int totalCount,ArrayList<String> tittles,ArrayList<String> values);
		public void OnGetFailed(int code,String msg);
	}
	
	@Weak
	public GetPatientDiagnoseInterface mInterface;
	
	
	public GetPatientDiagnoseLogic(GetPatientDiagnoseInterface mIn){
		this.mInterface = mIn;
	}
	
	public void getDianose(ArrayList<Integer> list,boolean isFromHome){
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
			if(!isFromHome){
				JSONArray mArray = new JSONArray(list);
				params.put("patient_ids", mArray);
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB
				+ "/home/get_patient_diagnose_count.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mInterface.OnGetFailed(code,e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					JSONObject mJsonObject = (JSONObject)results;
					int totalCount = mJsonObject.optInt("total_patient_count");
					JSONArray mArray = mJsonObject.optJSONArray("diagnose_patient_count");
					ArrayList<String> titles = new ArrayList<String>();
					ArrayList<String> values = new ArrayList<String>();
					if(mArray != null) {
					for(int i=0;i<mArray.length();i++){
						try {
							Iterator<String> iterator = mArray.getJSONObject(i).keys();
							while (iterator.hasNext()) {
								String title = iterator.next();
								String value = mArray.getJSONObject(i).optString(title);
//								map.put(title, value);
								titles.add(title);
								values.add(value);
							}
						} catch (JSONException e) {
							e.printStackTrace();
						}
					}
					
				}
					mInterface.OnGetSuccess(responseCode, totalCount, titles,values);
			}
			}
		});
	}
}
