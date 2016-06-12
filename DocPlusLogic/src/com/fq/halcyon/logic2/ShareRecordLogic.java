package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 分享病历和病案
 */
public class ShareRecordLogic {

	@Weak
	private ShareRecordCallBack onCallBack;
	private ShareRecordHandle mHandle;
	
	public ShareRecordLogic(ShareRecordCallBack onCallBack) {
		this.onCallBack = onCallBack;
		mHandle = new ShareRecordHandle();
	}
	
	/**
	 * 分享病案
	 * @param patientId
	 * @param doctorIds
	 */
	public void sharePatient(int patientId, ArrayList<Integer> doctorIds){
		HashMap<String, Object> map = new HashMap<String, Object>();
		JSONArray array = new JSONArray(doctorIds);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		map.put("doctor_ids", array);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/share.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 分享病历
	 * @param recordIds
	 * @param doctorIds
	 */
	public void shareRecord(ArrayList<Integer> recordIds, ArrayList<Integer> doctorIds){
		HashMap<String, Object> map = new HashMap<String, Object>();
		JSONArray recordArr = new JSONArray(recordIds);
		JSONArray doctorArr = new JSONArray(doctorIds);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_ids", recordArr);
		map.put("doctor_ids", doctorArr);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/share.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 分享病历记录
	 * @param recordItemIds
	 * @param doctorIds
	 */
	public void shareRecordItem(ArrayList<Integer> recordItemIds, ArrayList<Integer> doctorIds){
		HashMap<String, Object> map = new HashMap<String, Object>();
		JSONArray recordArr = new JSONArray(recordItemIds);
		JSONArray doctorArr = new JSONArray(doctorIds);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_item_ids", recordArr);
		map.put("doctor_ids", doctorArr);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/share.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public interface ShareRecordCallBack{
		public void shareRecordError(int code, String msg);
		public void shareRecordSuccess(int code, String msg);
	}
	
	class ShareRecordHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.shareRecordError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				onCallBack.shareRecordSuccess(responseCode, msg);
			}else{
				onCallBack.shareRecordError(responseCode, msg);
			}
		}
		
	}
}
