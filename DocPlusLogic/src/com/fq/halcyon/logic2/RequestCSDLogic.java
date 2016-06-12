package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.City;
import com.fq.halcyon.entity.Department;
import com.fq.halcyon.entity.Hospital;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class RequestCSDLogic {
	
	public void requestCity(final ResCityInf feed) {
		String url = UriConstants.Conn.URL_PUB + "/pub/list_cities.do";
		String localData = null;

		JSONObject localresult = null;
		JSONObject json = new JSONObject();
		if (localData == null || "".equals(localData)) {
			try {
				json.put("version", 0);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		} else {
			try {
				JSONObject local = new JSONObject(localData);
				localresult = local.optJSONObject("results");
				json.put("version", localresult.optInt("version"));
			} catch (Exception e1) {
				e1.printStackTrace();
				try {
					json.put("version", 0);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		}

		final JSONObject localResult = localresult;

		ApiSystem.getInstance().require(url, new FQHttpParams(json),
				API_TYPE.BROW, new HalcyonHttpResponseHandle() {
					@Override
					public void onError(int code,Throwable e) {
						if (localResult != null) {
							feed.feedCity(getCitysByJson(localResult));
						} else {
							feed.onError(code, e);
						}
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							JSONObject jsonObj = (JSONObject) results;
							if (jsonObj.isNull("citys")) {
								if (localResult != null) {
									feed.feedCity(getCitysByJson(localResult));
								} else {
									feed.onError(responseCode, new Throwable(msg));
								}
							} else {
								feed.feedCity(getCitysByJson(jsonObj));
							}
						} else {
							if (localResult != null) {
								feed.feedCity(getCitysByJson(localResult));
							} else {
								feed.onError(responseCode, new Throwable(msg));
							}
						}
					}
				});
	}

	public void requestDepartment(final FeedSaveDepartment callback) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		//map.put("dept_name", department);
		JSONObject json = JsonHelper.createJson(map);
		String url = UriConstants.Conn.URL_PUB+ "/pub/list_departments.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json),API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code,Throwable e) {
						callback.onError(code, e);
					}

					@Override
					public void handle(int responseCode, String msg, int type,Object results) {
						ArrayList<Department> departments = new ArrayList<Department>();
						if(responseCode == 0 && type == 2){
							JSONArray array = (JSONArray)results;
							for(int i = 0; i < array.length(); i++){
								try {
									JSONObject jobj = array.getJSONObject(i);
//									Department dep = EntityUtil.FromJson(jobj, Department.class);
									Department dep = new Department();
									dep.setAtttributeByjson(jobj);
									departments.add(dep);
								} catch (JSONException e) {
								}
							}
						}
						callback.feedDepartment(departments);
					}	
				});
	}

	public void requestHospital(String  cityName,boolean isSchool,final RequetHospitalInf inf){
		String url = "";
		JSONObject json = null;
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(isSchool){
			map.put("city_name", cityName);
			json = JsonHelper.createJson(map);
			url = UriConstants.Conn.URL_PUB+"/mediStudent/get_university_info.do";
		}else{
			map.put("user_id", Constants.getUser().getUserId());
			map.put("city_name", cityName);
			json = JsonHelper.createJson(map);
			url = UriConstants.Conn.URL_PUB+"/pub/list_hospitals.do";
		}
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.BROW, new HalcyonHttpResponseHandle() {
			public void onError(int code,Throwable e) {
				inf.onError(code, e);
			}
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 2){
					 JSONArray array = (JSONArray)results;
					 if(array == null)inf.onError(responseCode, new Throwable(msg));
					 
					 ArrayList<Hospital> hospitals = new ArrayList<Hospital>();
					 for(int i = 0; i < array.length(); i++){
						 try{
							// JSONObject obj = array.getJSONObject(i);
//							 Hospital hos = EntityUtil.FromJson( array.getJSONObject(i),Hospital.class); 
							 Hospital hos = new Hospital();
							 hos.setAtttributeByjson(array.getJSONObject(i));
							 hospitals.add(hos);
						 }catch (Exception e){
							 e.printStackTrace();
						 }
					 }
					 inf.feedHospital(hospitals);
				}else{
					inf.onError(responseCode, new Throwable(msg));
				}
			}
		});
	}
	
	public ArrayList<City> getCitysByJson(JSONObject json) {
		ArrayList<City> citys = new ArrayList<City>();
		try {
			JSONArray cityas = json.optJSONArray("citys");
			for (int i = 0; i < cityas.length(); i++) {
				try {
//					City city = EntityUtil.FromJson(cityas.getJSONObject(i),City.class);
					City city = new City();
					city.setAtttributeByjson(cityas.getJSONObject(i));
					citys.add(city);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} catch (Exception e) {
		}
		return citys;
	}

	public interface RequetHospitalInf{
		public void feedHospital(ArrayList<Hospital> hos);
		public void onError(int code,Throwable error);
	}

	public interface FeedSaveDepartment{
		public void feedDepartment(ArrayList<Department> departmets);
		public void onError(int code,Throwable error);
	}

	public interface ResCityInf{
		public void feedCity(ArrayList<City> citys);
		public void onError(int code,Throwable error);
	}
	
	public interface OnMajorCallback extends FQHttpResponseInterface {
//		public void feedMajor(ArrayList<Major> majors);
	}
}
