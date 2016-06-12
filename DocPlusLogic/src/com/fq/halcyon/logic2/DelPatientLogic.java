package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 删除病案
 */
public class DelPatientLogic {

	public DelMedicalCallBack onCallBack;
	
	public interface DelMedicalCallBack{
		public void onDelMedicalError(int code, String msg);
		public void onDelMedicalSuccess(int code, String msg);
	}
	
	public DelPatientLogic(final DelMedicalCallBack onCallBack) {
		this.onCallBack = onCallBack;
	}
	
	public void delMedical(int patientId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/delete.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class DelMedicalLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			if(onCallBack != null)onCallBack.onDelMedicalError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				if(onCallBack != null)onCallBack.onDelMedicalSuccess(responseCode, msg);
			}else{
				if(onCallBack != null)onCallBack.onDelMedicalError(responseCode, msg);
			}
		}		
	}
	
	private DelMedicalLogicHandle mHandle = new DelMedicalLogicHandle();
}
