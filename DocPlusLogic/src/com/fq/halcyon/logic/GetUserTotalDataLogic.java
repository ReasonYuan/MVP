package com.fq.halcyon.logic;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class GetUserTotalDataLogic {
	
	public void requestUserTotalData(final OnUserTotalDataCallback callback){
		HashMap<String,Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB+"/record/friend_recordItem_count.do";
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			public void onError(int code, Throwable e) {
				if(callback != null){
					int friend = Constants.contactsList == null?0:Constants.contactsList.size();
					callback.userDataCallback(0, 0, Constants.getUser().getDPMoney(), friend);
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(callback != null){
					if(responseCode == 0 && type == 1){
						JSONObject obj = (JSONObject) results;
						int patient = obj.optInt("countP");
						int record = obj.optInt("countRecord");
//						int dpmony = obj.optInt("dp_mony");
						int friend = obj.optInt("countT");
						callback.userDataCallback(patient, record, 0, friend);
					}else{
						int friend = Constants.contactsList == null?0:Constants.contactsList.size();
						callback.userDataCallback(0, 0, Constants.getUser().getDPMoney(), friend);
					}
				}
			}
		});
	}
	
	
	public interface OnUserTotalDataCallback{
		public void userDataCallback(int patientCount,int recordCount,int dpMoney,int friendCount);
	}
}
