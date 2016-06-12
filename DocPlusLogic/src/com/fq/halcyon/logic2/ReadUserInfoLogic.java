package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class ReadUserInfoLogic {

	
	public void readUserInfoByGet(String url,final OnReadInfoCallback callback){
		url = url+"&my_user_id="+Constants.getUser().getUserId();
		HttpHelper.sendGetRequest(url, new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				callback.onError(code, e);
			}
			public void handle(int responseCode, String msg, int type, Object results) {
				doResponseResult(responseCode, msg, type, results,callback);
			}
		});
	}
	
	public void readUserInfoByGet(int userId,final OnReadInfoCallback callback){
		String url = UriConstants.getUserURL()+"?user_id="+userId+"&my_user_id="+Constants.getUser().getUserId();
		
		HttpHelper.sendGetRequest(url, new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				callback.onError(code, e);
			}
			public void handle(int responseCode, String msg, int type, Object results) {
				doResponseResult(responseCode, msg, type, results,callback);
			}
		});
	}
	
	
	public void readUserInfoByPost(int userId,final OnReadInfoCallback callback){
		String url = UriConstants.getUserURL();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		map.put("my_user_id", Constants.getUser().getUserId());
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			public void onError(int code, Throwable e) {
				callback.onError(code, e);
			}
			
			public void handle(int responseCode, String msg, int type, Object results) {
				doResponseResult(responseCode, msg, type, results,callback);
			}
		});
	}
	
	private void doResponseResult(int responseCode, String msg, int type, Object results,OnReadInfoCallback callback){
		if(responseCode == 0 && type == 1){
			JSONObject mJsonObject = (JSONObject) results;
			Contacts user = new Contacts();
			user.setAtttributeByjson(mJsonObject);
			callback.feedUser(user);
		}else{
			callback.onError(-1, null);
		}
	}
	
	public interface OnReadInfoCallback {
		public void feedUser(Contacts user);
		public void onError(int code,Throwable error);
	}
}
