package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class AddRecordLogic {
	
	@Weak
	private AddRecordCallBack onCallBack;
	
	public interface AddRecordCallBack{
		public void AddRecordError(int code, String msg);
		public void AddRecordSuccess(int code, Patient medical,String msg);
	}
	
	public AddRecordLogic(final AddRecordCallBack onCallBack) {
		this.onCallBack = onCallBack;
	}
	
	/**
	 * 新建记录
	 * @param patientID
	 * @param patientName
	 */
	public void AddRecord(String patientName,int patientID,ArrayList<ArrayList<PhotoRecord>> mPhotoRecords){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("name", patientName);
		map.put("patient_id", patientID);
		ArrayList<JSONObject> arrayList = new ArrayList<JSONObject>();
		for(int i = 0; i < mPhotoRecords.size();i++){
			ArrayList<Integer> temList = new ArrayList<Integer>();
			for(int j=0;j<mPhotoRecords.get(i).size();j++){
				temList.add(mPhotoRecords.get(i).get(j).getImageId());
			}
			JSONArray array = new JSONArray(temList);
			Map<String, JSONArray> tmpMap = new HashMap<String, JSONArray>();
			tmpMap.put("records_images", array);
			JSONObject jsonObj = new JSONObject(tmpMap);
			arrayList.add(jsonObj);
		}
		JSONArray arr = new JSONArray(arrayList);
		map.put("records", arr);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/create.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public void AddRecord(String patientName,ArrayList<ArrayList<PhotoRecord>> mPhotoRecords){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("name", patientName);
		ArrayList<JSONObject> arrayList = new ArrayList<JSONObject>();
		for(int i = 0; i < mPhotoRecords.size();i++){
			ArrayList<Integer> temList = new ArrayList<Integer>();
			for(int j=0;j<mPhotoRecords.get(i).size();j++){
				temList.add(mPhotoRecords.get(i).get(j).getImageId());
			}
			JSONArray array = new JSONArray(temList);
			Map<String, JSONArray> tmpMap = new HashMap<String, JSONArray>();
			tmpMap.put("records_images", array);
			JSONObject jsonObj = new JSONObject(tmpMap);
			arrayList.add(jsonObj);
		}
		JSONArray arr = new JSONArray(arrayList);
		map.put("records", arr);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/create.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 添加图片到已经存在的记录里
	 * @param patientID
	 * @param itemId
	 * @param mPhotoRecords
	 */
	public void addRecord(int patientID,int itemId,ArrayList<ArrayList<PhotoRecord>> mPhotoRecords) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientID);
		map.put("item_id", itemId);
		ArrayList<JSONObject> arrayList = new ArrayList<JSONObject>();
		for(int i = 0; i < mPhotoRecords.size();i++){
			ArrayList<Integer> temList = new ArrayList<Integer>();
			for(int j=0;j<mPhotoRecords.get(i).size();j++){
				temList.add(mPhotoRecords.get(i).get(j).getImageId());
			}
			JSONArray array = new JSONArray(temList);
			Map<String, JSONArray> tmpMap = new HashMap<String, JSONArray>();
			tmpMap.put("records_images", array);
			JSONObject jsonObj = new JSONObject(tmpMap);
			arrayList.add(jsonObj);
		}
		JSONArray arr = new JSONArray(arrayList);
		map.put("records", arr);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/create.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class AddRecordLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.AddRecordError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject json = (JSONObject) results;
				Patient medical = new Patient();
				medical.setAtttributeByjson(json);
				onCallBack.AddRecordSuccess(responseCode, medical,msg);
			}else{
				onCallBack.AddRecordError(responseCode, msg);
				
			}
		}		
	}
	
	private AddRecordLogicHandle mHandle = new AddRecordLogicHandle();
}
