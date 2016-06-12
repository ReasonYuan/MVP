package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.SurveyPatientItem;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 病案概览
 * @author niko
 *
 */
public class SurveyPatientLogic {

	private SurveyPatientCallBack onCallBack;
	private ArrayList<SurveyPatientItem> surItemList;
	
	public SurveyPatientLogic(SurveyPatientCallBack onCallBack) {
		this.onCallBack = onCallBack;
		surItemList = new ArrayList<SurveyPatientItem>();
	}
	
	public interface SurveyPatientCallBack{
		public void onSurveyError(int code, String msg);
		public void onSurveyResult(int code, ArrayList<SurveyPatientItem> surItemList);
	}
	
	public void surveyPatient(final int patientId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/over_view_patient.do";
//		String uri = "http://192.168.3.101:8081/yiyi/test/survey_patient.do";
		HalcyonHttpResponseHandle mHandle =  new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				onCallBack.onSurveyError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (responseCode == 0 && type == 2) {
					JSONArray jsonArr = (JSONArray) results;
					int count = jsonArr.length();
					for (int i = 0; i <count; i++) {
						JSONObject jsonObj = jsonArr.optJSONObject(i);
						SurveyPatientItem item = new SurveyPatientItem();
						item.setAtttributeByjson(jsonObj);
						surItemList.add(item);
					}
					FileHelper.saveFile(results.toString(), FileSystem.getInstance().getUserCachePath()+patientId+"patient.survey", true);
					onCallBack.onSurveyResult(responseCode, surItemList);
				}else{
					onCallBack.onSurveyError(responseCode, msg);
				}
			}
		};
		if(Platform.isNetWorkConnect){
			ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		}else{
			String cache = FileHelper.readString(FileSystem.getInstance().getUserCachePath()+patientId+"patient.survey", true);
			if(cache != null && !cache.equals("")){
				try {
					mHandle.handle(0, cache, 2, new JSONArray(cache));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}else {
				ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
			}
		}
		
	}
}
