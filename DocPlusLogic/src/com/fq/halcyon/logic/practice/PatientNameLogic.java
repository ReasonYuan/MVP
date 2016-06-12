package com.fq.halcyon.logic.practice;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.PatientRecommendName;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 关于病案名字的接口，主要用于获得病案的推荐名字及修改病案的名字
 * @author reason
 */
public class PatientNameLogic {

	@Weak
	private PatientNameCalBack mCallback;
	
	
	public PatientNameLogic(PatientNameCalBack callback){
		mCallback = callback;
	}
	
	/**
	 * 获得系统推荐的某病历的名字列表
	 */
	public void loadPatientRecommendNames(int patientId){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("patient_id", patientId);
		}catch(Exception e){
			FQLog.i("构建请求'系统推荐病案名字'的参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/patient/get_meta_info.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallback.patientNameError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					JSONArray array = (JSONArray)results;
					ArrayList<PatientRecommendName> names = new ArrayList<PatientRecommendName>();
					for(int i = 0; i < array.length(); i++){
						JSONObject json = array.optJSONObject(i);
						if(json != null){
							PatientRecommendName name = new PatientRecommendName();
							name.setAtttributeByjson(json);
							if(!name.isEmpty()){
								names.add(name);
							}
						}
					}
					mCallback.recommendNameCallback(names);
				}else{
					mCallback.patientNameError(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 重命名病案名字
	 */
	public void renamePatientName(int patientId,String patientName){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("patient_id", patientId);
			params.put("patient_name", patientName);
		}catch(Exception e){
			FQLog.i("构建请求'重命名病案名字'的参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/patient/rename.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallback.patientNameError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mCallback.renamePatientSuccess();
				}else{
					mCallback.patientNameError(responseCode, msg);
				}
			}
		});
	}

	
	
	/**
	 * 关于病案名字处理的相关回调<br/>
	 * 病案推荐名称、重命名等
	 * 
	 * @author reason
	 */
	public interface PatientNameCalBack{
		
		/**
		 * 获得系统推荐的病案名字列表的回调
		 * @param names
		 */
		public void recommendNameCallback(ArrayList<PatientRecommendName> names);
		
		/**
		 * 重命名病案成功的回调
		 */
		public void renamePatientSuccess();
		
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void patientNameError(int code,String msg);
	}
}
