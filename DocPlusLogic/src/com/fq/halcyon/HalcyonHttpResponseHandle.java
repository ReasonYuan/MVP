package com.fq.halcyon;

import com.fq.http.potocol.FQJsonResponseHandle;
import com.fq.lib.FileHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "HalcyonHttpResponseHandle.h"
]-*/
@ObjectiveCName("HalcyonHttpResponseHandle")
public abstract class HalcyonHttpResponseHandle extends FQJsonResponseHandle{

	 public interface HalcyonHttpHandleDelegate{
		public void handleError(int errorCode,Throwable e);
		public void handleSuccess(Object object);
	}
	
	public static final int HALCYON_HTTP_RESPONSE_CODE_SUCCESS = 0;
	
	protected boolean loadCache = false;
	
	protected String path;
	
	protected String name;
	
	
	public void setPath(String path ,String name){
		this.path = path;
		this.name = name;
	}
	
	public boolean isLoadCache() {
		return loadCache;
	}

	public void setLoadCache(boolean loadCache) {
		this.loadCache = loadCache;
	}

	
	@Override
	public void handleJson(JSONObject json) {
		this.handleJson(json, true);
	}
	
	public void handleJson(JSONObject json,boolean isformNet) {
		int responseCode = json.optInt("response_code");
		String msg = json.optString("msg");
		Object results = json.opt("results");
		if(results != null){
			if(results instanceof JSONObject){
				handle(responseCode, msg, 1, results);
			}else if (results instanceof JSONArray) {
				handle(responseCode, msg, 2, results);
			}else{
                try {
					handle(responseCode, msg, 1, new JSONObject("{}"));
				} catch (JSONException e) {
				}
            }
			if(isformNet && responseCode == 0 && loadCache){
				FileHelper.saveFile(json.toString(), path, name,true);
			}
		}else {
			handle(json.optInt("response_code"), json.optString("msg"), 1, json);
		}
		
	}
	
	/**
	 * 
	 * @param responseCode 如果不为0，服务端出错
	 * @param msg  出错信息
	 * @param type type为1：results是jsonObject对象， 2则是jsonArray对象
	 * @param results 
	 */
	public abstract void handle(int responseCode,String msg,int type, Object results);

}
