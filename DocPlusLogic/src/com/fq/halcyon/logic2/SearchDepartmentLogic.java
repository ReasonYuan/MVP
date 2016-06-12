package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Department;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 搜索科室的逻辑
 * @author niko
 *
 */
public class SearchDepartmentLogic {

	private ArrayList<Department> mList;
	
	public interface SearchDepartmentCallBack{
		public void onSearchDepartmentError(int code, String msg);
		public void onSearchDepartmentResult(ArrayList<Department> mList);
	}
	
	@Weak
	private SearchDepartmentCallBack onCallBack;
	
	public SearchDepartmentLogic(SearchDepartmentCallBack onCallBack) {
		mList = new ArrayList<Department>();
		this.onCallBack = onCallBack;
	}
	
	/**
	 * 搜索科室
	 * @param departmentName
	 */
	public void searchDepartment(String departmentName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("key_word", departmentName);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/pub/list_second_department.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class SearchDepartmentHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onSearchDepartmentError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0&& type == 2 ) {
				JSONArray jsonArray = (JSONArray) results;
				for (int i = 0; i < jsonArray.length(); i++) {
					Department department = new Department();
					department.setAtttributeByjson(jsonArray.optJSONObject(i));
					mList.add(department);
				}
				onCallBack.onSearchDepartmentResult(mList);
			}else{
				onCallBack.onSearchDepartmentError(responseCode, msg);
			}
		}
	}
	
	private SearchDepartmentHandle mHandle = new SearchDepartmentHandle();
}
