package com.fq.halcyon.logic.practice;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.SearchParams;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class SearchCriteriaLogic {
	
	public interface DeleteSearchCriteriaInterface {
		public void onDeleteError(int code,String msg);
		public void onDeleteSuccess();
	}
	
	public interface SaveSearchCriteriaInterface {
		public void onSaveError(int code,String msg);
		public void onSaveSuccess();
	}
	
	public interface GetSearchCriteriaInterface {
		public void onGetError(int code,String msg);
		public void onGetSuccess(ArrayList<SearchParams> searchParamss);
	}
	
	@Weak
	public DeleteSearchCriteriaInterface mDeleteInterface;
	
	@Weak
	public SaveSearchCriteriaInterface mSaveInterface;
		
	@Weak
	public GetSearchCriteriaInterface mGetInterface;
	
	
	public SearchCriteriaLogic(){
		
	}
	
	/**
	 * 删除搜索结果
	 * @param conditions
	 */
	public void DeleteSearchCondition(ArrayList<Integer> conditions,DeleteSearchCriteriaInterface mIn){
		this.mDeleteInterface = mIn;
		JSONObject params = new JSONObject();
		try {
//			params.put("user_id", Constants.getUser().getUserId());
			JSONArray mArray = new JSONArray(conditions);
			params.put("id", mArray);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		String url =  UriConstants.Conn.URL_PUB
				+ "/record/delete_search_condition.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mDeleteInterface.onDeleteError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					mDeleteInterface.onDeleteSuccess();
				}else{
					mDeleteInterface.onDeleteError(responseCode, msg);
				}
			}
		});
	}
	
	/**
	 * 保存搜索结果
	 */
	public void SaveSearchCondition(SearchParams searchParams,ArrayList<Integer> patientIds,SaveSearchCriteriaInterface mIn){
		
		this.mSaveInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
			params.put("search_name", searchParams.getName());
			params.put("data_filter", searchParams.getKey());
			params.put("filters", searchParams.getFiltersJson());
			
			if (patientIds.size() != 0) {
				JSONArray array = new JSONArray(patientIds);
				params.put("patient_ids", array);
			}else{
				JSONArray array = new JSONArray();
				params.put("patient_ids", array);
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		String url =  UriConstants.Conn.URL_PUB
				+ "/record/save_search_condition.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mSaveInterface.onSaveError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					mSaveInterface.onSaveSuccess();
				}else{
					mSaveInterface.onSaveError(responseCode, msg);
				}
			}
		});
		
	}
	
	/**
	 * 获取搜索结果
	 */
	public void GetSearchCondition(int page,int pageSize,GetSearchCriteriaInterface mIn){
		this.mGetInterface = mIn;
		JSONObject mJsonObject = new JSONObject();
		try {
			mJsonObject.put("user_id", Constants.getUser().getUserId());
			mJsonObject.put("page", page);
			mJsonObject.put("page_size", pageSize);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		String url = UriConstants.Conn.URL_PUB
				+ "/record/query_search_condition.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(mJsonObject), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mGetInterface.onGetError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (responseCode == 0) {
					try {
						ArrayList<SearchParams> searchParamss = new ArrayList<SearchParams>();
						JSONArray mArray = new JSONArray(results.toString());
						for (int i = 0; i < mArray.length(); i++) {
							JSONObject obj = mArray.getJSONObject(i);
							int id = obj.optInt("id");
							String name = obj.optString("search_name");
							String key = obj.optString("data_filter");
							JSONArray patientsArray = obj.optJSONArray("patient_ids");
							ArrayList<Integer> patientIds  = new ArrayList<Integer>();
							if (patientsArray != null){
								for (int j = 0 ; j < patientsArray.length() ; j++) {
									Integer patientID = (Integer) patientsArray.get(j);
									patientIds.add(patientID);
								}
							}
							JSONArray filtersArray = obj.optJSONArray("filters");
							SearchParams searchParams = new SearchParams();
							searchParams.setPatientIds(patientIds);
							searchParams.setName(name);
							searchParams.setId(id);
							searchParams.setKey(key);
							searchParams.setFilters(filtersArray);
							searchParamss.add(searchParams);
						}
						mGetInterface.onGetSuccess(searchParamss);
					} catch (JSONException e) {
						e.printStackTrace();
					}
					
					
				}else{
					mGetInterface.onGetError(responseCode,msg);
				}
			}
		});
	}
}
