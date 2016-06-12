package com.fq.lib;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;

public class JsonHelper {

	protected static String TAG = "JsonHelper";
	
	public static final String REQ_RECORD = "record";
	public static final String REC_CODE = "response_code";
	public static final String REC_MSG = "msg";
	public static final String REC_RESULT = "results";
	public static final int REC_CODE_SUCC = 0;

	/**
	 * 构建含有user_id的JsonObject
	 * @return JSONObject 含有"user_id"的jsonObject数据
	 */
	public static JSONObject createUserIdJson(){
		JSONObject json = new JSONObject();
		try {
			json.put("user_id", Constants.getUser().getUserId());
		} catch (JSONException e) {
			FQLog.i("构建含有用户id的json数据时出错");
			e.printStackTrace();
		}
		return json;
	}
	
	/**
	 * 将map类型的数据转化成jsonObject
	 * @param map
	 * @return
	 */
	public static JSONObject createJson(Map<String, Object> map){
		JSONObject json = new JSONObject();
//		JSONObject record = new JSONObject();
		try {
//			json.put(REQ_RECORD, record);
			
			if(map != null){
				Set<String> keySet = map.keySet();
				Iterator<String> i = keySet.iterator();
				
				while(i.hasNext()){
					String key = i.next();
					json.put(key, map.get(key));
		        }  
			}
		} catch (JSONException e) {
			FQLog.print(TAG,"createJson put attr error");
		}
		return json;
	}
	
	public static JSONObject createJsonForDebug(Map<String, Object> map){
		JSONObject json = new JSONObject();
//		JSONObject record = new JSONObject();
		try {
//			json.put(REQ_RECORD, record);
			
			if(map != null){
				Set<String> keySet = map.keySet();
				Iterator<String> i = keySet.iterator();
				
				while(i.hasNext()){
					String key = i.next();
					json.put(key, map.get(key));
		        }  
			}
		} catch (JSONException e) {
			FQLog.print(TAG,"createJson put attr error");
		}
		return json;
	}
	
	
	
	public static JSONArray parseJsonArray(String jsonString){
		JSONArray mJsonArray = null;
		try {
			JSONObject mObject = new JSONObject(jsonString);
			int mResponseCode = mObject.getInt(REC_CODE);
			switch (mResponseCode) {
			case REC_CODE_SUCC://服务器操作成功
				 mJsonArray = mObject.getJSONArray(REC_RESULT);
				break;
			default:
				String msg = mObject.getString(REC_MSG);
				FQLog.print(TAG,"resquest JsonObject error!"+msg);
				break;
			}
			
		} catch (JSONException e) {
			FQLog.print(TAG,"parseJsonArray error!");
			e.printStackTrace();
		}
		return mJsonArray;
	}
	
	public static JSONObject parseJsonObject(String jsonObject){
		JSONObject mJsonObject = null;
		
		try {
			JSONObject mObject = new JSONObject(jsonObject);
			int mResponseCode = mObject.getInt(REC_CODE);
			switch (mResponseCode) {
			case REC_CODE_SUCC:
				mJsonObject  = mObject.getJSONObject(REC_RESULT);
				break;
			default:
				String msg = mObject.getString(REC_MSG);
				FQLog.print(TAG,"resquest JsonObject error!"+msg);
				break;
			}
		} catch (JSONException e) {
			FQLog.print(TAG,"parseJsonObject error!");
			e.printStackTrace();
		}
		return mJsonObject;
	}
	
	public static JSONArray parseJsonArray(JSONObject json, FQHttpResponseInterface inf){
		if(json == null){
			inf.onError(-21, new Throwable("(JsonHelper)get network data json is null"));
			return null;
		}
		int mResponseCode = json.optInt(REC_CODE,-1);
			
		if(mResponseCode == REC_CODE_SUCC){
			try{				
				JSONArray jsonArray = json.getJSONArray(REC_RESULT);
				return jsonArray;
			}catch(Exception e){
				inf.onError(-22, new Throwable("(JsonHelper)"+e.getMessage()));
			}
		}else{
			inf.onError(mResponseCode, new Throwable(json.optString(REC_MSG)));
		}
		return null;
	}
	
	public static JSONObject parseJsonObject(JSONObject json, FQHttpResponseInterface inf){
		if(json == null){
			inf.onError(-21, new Throwable("(JsonHelper)get network data json is null"));
			return null;
		}
		
		int mResponseCode = json.optInt(REC_CODE,-1);
		
		if(mResponseCode == REC_CODE_SUCC){
			try{
				JSONObject jsonObject = json.getJSONObject(REC_RESULT);
				return jsonObject;
			}catch (Exception e){
				inf.onError(-22, new Throwable("(JsonHelper)"+e.getMessage()));
			}		
		}else{
			inf.onError(mResponseCode, new Throwable(json.optString(REC_MSG)));
		}
		return null;
	}
	
	public static JSONObject loadJsonObjectByFile(String path,String name){
		String jsonStr = FileHelper.readString(path, name,false);
		if("".equals(jsonStr))return null;
		return parseJsonObject(jsonStr);
	}
}
