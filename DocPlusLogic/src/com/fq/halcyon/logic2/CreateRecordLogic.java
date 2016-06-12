package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Record;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 新建病历
 */
public class CreateRecordLogic {

	private CreateRecordFolderCallBack onCallBack;
	private CreateRecordFolderHandle mHandle;
	
	public interface CreateRecordFolderCallBack{
		public void onCreateFolderError(int code, String msg);
		public void onCreateFolderSuccess(int code, Record record);
	}
	
	public CreateRecordLogic(final CreateRecordFolderCallBack onCallBack) {
		this.onCallBack = onCallBack;
		mHandle = new CreateRecordFolderHandle();
	}
	
	/**
	 * 行医助手调用
	 * @param recordName  -病历名称
	 * @param patientId -病案ID
	 * @param recordCategory -病历类型（1：住院，2：门诊）
	 */
	public void createRecordFolder(String recordName, int patientId , int recordCategory){
		HashMap<String , Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		map.put("record_name", recordName);
		map.put("record_category", recordCategory);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/create.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class CreateRecordFolderHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onCreateFolderError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject json = (JSONObject) results;
				Record record = new Record();
				record.setAtttributeByjson(json);
				onCallBack.onCreateFolderSuccess(responseCode, record);
			}else{
				onCallBack.onCreateFolderError(responseCode, msg);
			}
		}
		
	}
}
