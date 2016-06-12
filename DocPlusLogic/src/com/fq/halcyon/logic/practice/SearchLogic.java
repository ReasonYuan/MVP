package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.halcyon.entity.practice.SearchFilter;
import com.fq.halcyon.entity.practice.SearchParams;
import com.fq.halcyon.practice.SearchHistoryManager;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 搜索病案、病历记录的接口
 * @author reason
 *
 */
public class SearchLogic {
	
	@Weak
	private SearchCallBack mCallBack;
	
	private HalcyonHttpResponseHandle mHandle;
	
	private SearchParams searchParams = new SearchParams();

	public SearchLogic(SearchCallBack callBack) {
		mCallBack = callBack;
		mHandle =  new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallBack.searchError(code, Constants.Msg.NET_ERROR);
				localSearch();
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					JSONObject json = (JSONObject) results;
					
					//解析返回的病案列表
					ArrayList<PatientAbstract> patients = null;
					JSONArray patArray = json.optJSONArray("patients");
					if(patArray != null){
						patients = new ArrayList<PatientAbstract>();	
						for(int i = 0; i < patArray.length(); i++){
							PatientAbstract patient = new PatientAbstract();
							patient.setAtttributeByjson(patArray.optJSONObject(i));
							patients.add(patient);
						}
					}else if(searchParams.getResponseType() != SearchParams.RESPONSE_RECORD){
						patients = new ArrayList<PatientAbstract>();
					}
					
					//解析返回的记录列表
					ArrayList<RecordAbstract> records = null;
					JSONArray recArray = json.optJSONArray("record_items");
					if(recArray != null){
						records = new ArrayList<RecordAbstract>();
						for(int i = 0; i < recArray.length(); i++){
							RecordAbstract record = new RecordAbstract();
							record.setAtttributeByjson(recArray.optJSONObject(i));
							records.add(record);
						}
					}else if(searchParams.getResponseType() != SearchParams.RESPONSE_PATIENT){
						records = new ArrayList<RecordAbstract>();
					}
					
					//解析返回的筛选选项列表
					ArrayList<SearchFilter> filters = null;
					JSONArray filArray = json.optJSONArray("filters");
					if(filArray != null){
						filters = new ArrayList<SearchFilter>();	
						for(int i = 0; i < filArray.length(); i++){
							SearchFilter filter = new SearchFilter();
							filter.setAtttributeByjson(filArray.optJSONObject(i));
							filters.add(filter);
						}
					}else if(searchParams.getNeedFilters() == SearchParams.FILTERS_NEED){
						filters = new ArrayList<SearchFilter>();
					}
					
					//保存搜索列表
//					if(searchParams.getResponseType() == SearchParams.RESPONSE_ALL){
//						SearchHistoryManager.getInstance().saveSearchResult(searchParams.getKey(), patients, records);
//					}
					
					mCallBack.searchRetrunData(patients, records, filters);
				}else{
					mCallBack.searchError(responseCode, msg);
				}
			}
		};
	}
	
	
	
	/**
	 * 搜索病案或记录
	 * @param searchParams 搜索时需要向服务器请求的参数
	 */
	public void search(final SearchParams searchParams){
		String url = UriConstants.Conn.URL_PUB+"/record/search_patients_items.do";
		
		JSONObject params = searchParams.getSearhParams();
		this.searchParams = searchParams;
        System.out.println(searchParams);
		if(Platform.isNetWorkConnect){
			ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, mHandle);
		}else{
			localSearch();
		}
		
	}
	
	public void searchWithFilters(Map<String, List<String>> map) {
		JSONArray jsonArray = new JSONArray();
		Set<String> keys = map.keySet();
		for (String key : keys) {
			JSONObject jsonObj = new JSONObject();
			try {
				jsonObj.put("category", key);
				jsonObj.put("items", map.get(key));
				jsonArray.put(jsonObj);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}
	
	private void localSearch(){
		mHandle.handleBinaryData(Platform.getInstance().search(searchParams.getKey()).getBytes());
	}
	
	
	/**
	 * 搜索病案和记录时的回调接口
	 * @author reson
	 */
	public interface SearchCallBack {
		/**
		 * @param patients 搜索出来的病案列表。如果只请求记录，没有则会返回null，另外两种类型不会为null;
		 * @param records 搜索出来的病历记录列表。如果只请求病案，没有则会返回null，另外两种类型不会为null;
		 * @param filters 搜索后出来的可以筛选的数据的列表。如果不需要返回筛选项，则会为null   
		 */
		public void searchRetrunData(ArrayList<PatientAbstract>patients,ArrayList<RecordAbstract>records,ArrayList<SearchFilter> filters);

		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void searchError(int code, String msg);
		
	}

}
