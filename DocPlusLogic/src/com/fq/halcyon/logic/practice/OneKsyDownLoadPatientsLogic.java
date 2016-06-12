package com.fq.halcyon.logic.practice;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class OneKsyDownLoadPatientsLogic {

	public interface OneKsyDownLoadPatientsDelegate{
		
		/**
		 * 下载出错
		 * @param code
		 * @param msg
		 */
		public void onError(int code,String msg);
		
		/**
		 * 当前病案是否已经下载或有更新
		 * @param patinetId
		 * @return true 要下载
		 */
		public boolean canUpdate(int patinetId,String updateTime);
		
		/**
		 * 下载进度 （0-100）
		 * @param process
		 */
		public void onProcess(int process);
		
		/**
		 * 成功下载一个病案
		 * @param str
		 */
		public void onDownloadRecord(String str);
	}
	
	private ArrayList<Integer> mDownloadList;
	
	@Weak
	private OneKsyDownLoadPatientsDelegate mDelegate;
	
	private int currentDownIndex;
	
	public OneKsyDownLoadPatientsLogic(OneKsyDownLoadPatientsDelegate delegate) {
		mDownloadList = new ArrayList<Integer>();
		mDelegate = delegate;
	}
	
	public void cancel(){
		mDownloadList.clear();
	}
	
	/**
	 * 一键下载
	 */
	public void oneKeyDownload(){
		currentDownIndex = 0;
		JSONObject jsonObject = new JSONObject();
		try {
			jsonObject.put("user_id", Constants.getUser().getUserId());
			jsonObject.put("page", 1);
			jsonObject.put("page_size", Integer.MAX_VALUE);
		} catch (Exception e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB+"/patient/get_recent_patients.do", new FQHttpParams(jsonObject), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				if(mDelegate != null) mDelegate.onError(code,"下载文件错误，请重试！");
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 2){
					JSONArray array = (JSONArray) results;
					if(array.length() > 0){
						for (int i = 0; i < array.length(); i++) {
							JSONObject jObject = array.optJSONObject(i);
							if(jObject != null){
								int patientId = jObject.optInt("patient_id");
								boolean canDownload = true;
								if(mDelegate != null){
									canDownload = mDelegate.canUpdate(patientId,jObject.optString("updated_at"));
								}
								if(canDownload)mDownloadList.add(patientId);
							}
						}
						currentDownIndex = 0;
						downRecord();
					}
				}
				
			}
		});
	}
	
	//下载
	private void downRecord(){
		if(!mDownloadList.isEmpty() && currentDownIndex != mDownloadList.size()){
			String url = UriConstants.Conn.URL_PUB + "/record/patient/download_patient.do";
			JSONObject params = JsonHelper.createUserIdJson();
			try {
				params.put("patient_id", mDownloadList.get(currentDownIndex));
			} catch (JSONException e) {
				e.printStackTrace();
			}
			FQHttpParams hparams = new FQHttpParams(params);
			ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,new HalcyonHttpResponseHandle() {
				
				@Override
				public void onError(int code, Throwable e) {
					currentDownIndex ++;
					if(mDelegate != null) {
						mDelegate.onProcess((int)((currentDownIndex/(float)mDownloadList.size())*100));
					}
					downRecord();
				}
				
				@Override
				public void handleJson(JSONObject json) {
					currentDownIndex ++;
					if(mDelegate != null) {
						mDelegate.onDownloadRecord(json.toString());
						mDelegate.onProcess((int)((currentDownIndex/(float)mDownloadList.size())*100));
					}
					downRecord();
				}
				
				@Override
				public void handle(int responseCode, String msg, int type, Object results) {
					// TODO Auto-generated method stub
					
				}
			});
		}else {
			//下载完成
			if(mDelegate != null) {
				mDelegate.onProcess(100);
			}
		}
	}

}
