package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Patient;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 获取病案列表
 */
public class GetPatientListLogic {

	private ArrayList<Patient> medicalList;
	public GetMedicalListCallBack onCallBack;
	public GetMedicalListHandle mHandle;
	
	public interface GetMedicalListCallBack{
		public void onGetMedicalListError(int code, String msg);
		public void onGetMedicalListResult(ArrayList<Patient> medicalList);
	};
	
	public GetPatientListLogic(final GetMedicalListCallBack onCallBack) {
		this.onCallBack = onCallBack;
		medicalList = new ArrayList<Patient>();
		mHandle = new GetMedicalListHandle();
	}
	
	public void getMedicalList(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/get_patient_list.do";
		
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	class GetMedicalListHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onGetMedicalListError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0 && type == 2){
				JSONArray jsonArr = (JSONArray) results;
				int count = jsonArr.length();
				for (int i = 0; i < count; i++) {
					try {
						JSONObject obj = jsonArr.getJSONObject(i);
						Patient medical = new Patient();
						medical.setAtttributeByjson(obj);
						medicalList.add(medical);
						onCallBack.onGetMedicalListResult(medicalList);
					} catch (JSONException e) {
						onCallBack.onGetMedicalListError(responseCode, e.getMessage());
					}
				}
				
			}else{
				onCallBack.onGetMedicalListError(responseCode, msg);
			}
		}
		
	}
}
