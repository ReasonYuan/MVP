package com.fq.halcyon.logic.practice;

import java.io.UnsupportedEncodingException;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class DownloadPatientLogic {

	public interface DownloadPatientCallBack {
		public void downloadPatientSuccess(String result);
		public void downloadPatientError(int code, String error);
	}
	
	@Weak
	private DownloadPatientCallBack onCallBack;
	
	public DownloadPatientLogic(DownloadPatientCallBack onCallBack) {
		this.onCallBack = onCallBack;
	}
	
	public void downloadPatient(int patientId) {
		String url = UriConstants.Conn.URL_PUB + "/record/patient/download_patient.do";
		JSONObject params = JsonHelper.createUserIdJson();
		try {
			params.put("patient_id", patientId);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		FQHttpParams hparams = new FQHttpParams(params);
		ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,new DownloadPatientHandle());
	}
	
	class DownloadPatientHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.downloadPatientError(code, e.getMessage());
		}

		@Override
		public void handleBinaryData(byte[] data) {
			try {
				String str = new String(data,"UTF-8");
				onCallBack.downloadPatientSuccess(str);
			} catch (UnsupportedEncodingException e) {
				onCallBack.downloadPatientError(-1, e.getMessage());
			}
		}
		
		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
		}
		
	}
}
