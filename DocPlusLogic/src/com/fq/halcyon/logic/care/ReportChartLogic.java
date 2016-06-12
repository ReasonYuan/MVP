package com.fq.halcyon.logic.care;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalcyonHttpResponseHandle.HalcyonHttpHandleDelegate;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.care.MedicalReport;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class ReportChartLogic {

	@Weak
	private HalcyonHttpHandleDelegate delegate;
	
	public ReportChartLogic(HalcyonHttpHandleDelegate callback) {
		this.delegate = callback;
	}
	
	public void getRreport(int patientId,int page){
		if(patientId == 0) return;
		JSONObject params = new JSONObject();
		if(page < 1) page = 1;
		try {
			params.put("user_id", Constants.getUser().getUserId());
			params.put("patient_id", patientId);
			params.put("page", page);
			params.put("page_size", 20);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB+"/record/patient/get_physical_exam.do", new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				if(delegate != null) delegate.handleError(code, e);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 2){
					JSONArray result = (JSONArray) results;
					ArrayList<MedicalReport> reports = new ArrayList<MedicalReport>();
					for (int i = 0; i < result.length(); i++) {
						JSONObject object = result.optJSONObject(i);
						if(object != null){
							MedicalReport item = new MedicalReport();
							item.setAtttributeByjson(object);
							reports.add(item);
						}
					}
					if(delegate != null) delegate.handleSuccess(reports);
				}
			}
		});
	}

}
