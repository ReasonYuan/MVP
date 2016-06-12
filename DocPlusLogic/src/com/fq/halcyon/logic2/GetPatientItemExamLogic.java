package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.ItemExam;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetPatientItemExamLogic {

	private int pageIndex;
	
	@Weak
	public GetPatientItemExamCallBack onCallBack;
	
	public GetPatientItemExamHandle mHandle;
	
	public interface GetPatientItemExamCallBack{
		public void GetPatientItemExamError(int code, String msg);
		public void GetPatientItemExamResult(ArrayList<ItemExam> itemExamList);
	};
	
	public GetPatientItemExamLogic(final GetPatientItemExamCallBack onCallBack) {
		this.onCallBack = onCallBack;
		mHandle = new GetPatientItemExamHandle();
	}
	
	public void GetPatientItemExam(int infoId,int itemId,String itemName,String itemUnit,int page,int pageSize){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("record_info_id", infoId);
		map.put("record_item_id", itemId);
		map.put("item_name", itemName);
		map.put("item_unit", itemUnit);
		map.put("page", page);
		map.put("page_size", pageSize);
		pageIndex = page;
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/get_patient_item_exam.do";
		
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	class GetPatientItemExamHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.GetPatientItemExamError(code, Constants.Msg.NET_ERROR);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			ArrayList<ItemExam> itemExamList = new ArrayList<ItemExam>();
			if(responseCode == 0){
				JSONArray array = (JSONArray) results;
				for(int i=0; i<array.length();i++){
					ItemExam exam = new ItemExam();
					exam.setAtttributeByjson(array.optJSONObject(i));
					if(exam.getExamValue().matches("[0-9]+")){
						itemExamList.add(exam);
					}
				}
				if(pageIndex == 1){
					if(itemExamList.size() < 2){
						itemExamList.clear();
					}
				}
					onCallBack.GetPatientItemExamResult(itemExamList);
			}else{
				onCallBack.GetPatientItemExamError(responseCode, msg);
			}
		}
	}
}