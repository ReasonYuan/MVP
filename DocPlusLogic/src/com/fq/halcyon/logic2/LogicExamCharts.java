package com.fq.halcyon.logic2;

import com.fq.http.potocol.PracticeResponseHandle;
import com.fq.lib.HttpHelper;
import com.fq.lib.json.JSONArray;

public class LogicExamCharts {

	public ExamRequestCallBack mCallback;
	
	public LogicExamCharts(ExamRequestCallBack callback){
		mCallback = callback;
	}
	
	public void requestExamData(int patientId,String examName){
		//String url = "http://120.25.164.106:3000/api/v1/exams?patient_id="+patientId+"&item_name="+examName+"&sort={'report_time':1,'insert_time':1}&select=item_name,report_time,insert_time,item_unit,exam_value";
		String url = "http://120.25.164.106:3000/api/v1/exams?patient_id="+patientId+"&item_name="+examName+"&sort={'report_time':1,'insert_time':1}&select=item_name,report_time,item_unit,exam_value";
		
		
		HttpHelper.sendGetRequest(url, new PracticeResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				if(mCallback != null)mCallback.requestError(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0){
					JSONArray array = (JSONArray) results;
					if(mCallback != null)mCallback.requestBack(array);
				}else{
					if(mCallback != null)mCallback.requestError(msg);
				}
			}
		});
	}
	
	
	public interface ExamRequestCallBack{
		public void requestError(String json);
		public void requestBack(JSONArray array);
	}
}
