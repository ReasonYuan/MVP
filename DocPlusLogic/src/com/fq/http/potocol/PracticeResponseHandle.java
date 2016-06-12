package com.fq.http.potocol;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public abstract class PracticeResponseHandle extends FQStringResponseHandle {

	@Override
	public void handleString(String value) {
		try {
			String json = value;
			json =  json.replaceAll("null", "\"null\"");
			json =  json.replaceAll("\"\"null\"\"", "\"null\"");
			json = json.trim();
			if(json.startsWith("{")){
				JSONObject jsonObject = new  JSONObject(json);
				handle(0, json, 1, jsonObject);
			}else{
				JSONArray array = new JSONArray(json);
				handle(0, json, 2, array);
			}
		} catch (Exception e) {
			e.printStackTrace();
			onError(0,e);
		}
	}
	
	public abstract void handle(int responseCode, String msg, int type, Object results);
	

}
