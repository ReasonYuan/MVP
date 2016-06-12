package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Hospital;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 搜索医院的逻辑
 * @author niko
 *
 */
public class SearchHospitalLogic {

	private ArrayList<Hospital> mList;
	
	public interface SearchHospitalCallBack{
		public void onSearchHospitalError(int code, String msg);
		public void onSearchHospitalResult(ArrayList<Hospital> mList);
	}
	
	@Weak
	private SearchHospitalCallBack onCallBack;
	
	public SearchHospitalLogic(SearchHospitalCallBack onCallBack) {
		mList = new ArrayList<Hospital>();
		this.onCallBack = onCallBack;
	}
	
	/**
	 * 搜索医院
	 * @param hospitalName
	 * @param cityName
	 */
	public void searchHospital(String hospitalName, String cityName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("hospital_name", hospitalName);
		map.put("city_name", cityName);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/pub/fuzzy_search_hospital.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 搜索HDR系统中的医院
	 * @param hospitalName
	 * @param cityName
	 */
	public void searchHDRHospital(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/pub/getHospital.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class SearchHospitalHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onSearchHospitalError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0 && type == 2) {
				JSONArray jsonArray = (JSONArray) results;
				for (int i = 0; i < jsonArray.length(); i++) {
					Hospital hospital = new Hospital();
					hospital.setAtttributeByjson(jsonArray.optJSONObject(i));
					mList.add(hospital);
				}
				onCallBack.onSearchHospitalResult(mList);
			}else{
				onCallBack.onSearchHospitalError(responseCode, msg);
			}
		}
	}
	
	private SearchHospitalHandle mHandle = new SearchHospitalHandle();
}
