package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Patient;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 新建病案
 */
public class CreatePatientLogic {

	private CreateMedicalCallBack onCallBack;
	
	public interface CreateMedicalCallBack{
		public void createMedicalError(int code, String msg);
		public void createMedicalSuccess(int code, Patient medical);
	}
	
	public CreatePatientLogic(final CreateMedicalCallBack onCallBack) {
		this.onCallBack = onCallBack;
	}
	
	/**
	 * 创建病历
	 * @param doctorId
	 * @param patientName
	 */
	public void createMedical(String patientName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_name", patientName);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/create.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class CreateMedicalLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.createMedicalError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject json = (JSONObject) results;
				Patient medical = new Patient();
				medical.setAtttributeByjson(json);
				onCallBack.createMedicalSuccess(responseCode, medical);
			}else{
				onCallBack.createMedicalError(responseCode, msg);
				
			}
		}		
	}
	
	private CreateMedicalLogicHandle mHandle = new CreateMedicalLogicHandle();
}
