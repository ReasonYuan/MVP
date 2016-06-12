package com.fq.halcyon.logic;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;

public class SaveCDSLogic {
	
	public void saveCity(String cityName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("city_name", cityName);
		JSONObject json = JsonHelper.createJson(map);
		//HttpHelper.sendPostRequest(Constants.Conn.URL_PUB+"/doctors/ save_city.do", new FQHttpParams(json), null);
		
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB+"/doctors/save_city.do", new FQHttpParams(json), API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				FQLog.i("error", "msg:"+e);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				FQLog.i("error", "results:"+results.toString());
			}
		});
	}
	
	public void saveDepartment(String department){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("dept_name", department);
		JSONObject json = JsonHelper.createJson(map);
//		HttpHelper.sendPostRequest(Constants.Conn.URL_PUB+"/doctors/save_department.do", new FQHttpParams(json), new HalcyonHttpResponseHandle() {
//			
//			@Override
//			public void onError(int code, String msg) {
//				FQLog.i("error", "msg:"+msg);
//			}
//			
//			@Override
//			public void handle(int responseCode, String msg, int type, Object results) {
//				FQLog.i("error", "results:"+results.toString());
//			}
//		});
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB+"/doctors/save_department.do", new FQHttpParams(json), API_TYPE.BROW, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				FQLog.i("error", "msg:"+e);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				FQLog.i("error", "results:"+results.toString());
			}
		});
	}
	
	public void saveHospital(String hospital,String city){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("hospital_name", hospital);
		map.put("city_name", city);
		JSONObject json = JsonHelper.createJson(map);
//		HttpHelper.sendPostRequest(Constants.Conn.URL_PUB+"/doctors/save_hospital.do", new FQHttpParams(json), null);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB+"/doctors/save_hospital.do", new FQHttpParams(json), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				FQLog.i("error", "msg:"+e);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				FQLog.i("error", "results:"+results.toString());
			}
		});
	}
	
	public interface FeedSaveHospital{
		
	}

	public interface FeedSaveDepartment{
		
	}
	
	public interface FeedSaveCity{
		
	}
}
