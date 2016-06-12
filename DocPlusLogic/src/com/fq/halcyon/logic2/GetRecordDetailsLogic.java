package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.StandardExamRecord;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class GetRecordDetailsLogic {

	public GetRecordDetailsCallBack onCallBack;
	public GetRecordDetailsHandle mHandle;
	
	public interface GetRecordDetailsCallBack{
		public void GetRecordDetailsError(int code, String msg);
		public void GetRecordDetailsResult(StandardExamRecord examItemList);
	};
	
	public GetRecordDetailsLogic(final GetRecordDetailsCallBack onCallBack) {
		this.onCallBack = onCallBack;
		mHandle = new GetRecordDetailsHandle();
	}
	
	public void GetRecordDetails(int infoId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_info_id", infoId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/get_item_info.do";
		
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	class GetRecordDetailsHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.GetRecordDetailsError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				JSONObject objct = (JSONObject) results;
				StandardExamRecord exam = new StandardExamRecord();
					exam.setAtttributeByjson(objct);
					onCallBack.GetRecordDetailsResult(exam);
			}else{
				onCallBack.GetRecordDetailsError(responseCode, msg);
			}
		}
	}
}