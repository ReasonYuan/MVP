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

public class ModifyRecordNameLogic {

	private ModifyRecordNameCallBack onCallBack;
	
	public ModifyRecordNameLogic(ModifyRecordNameCallBack onCallBack) {
		this.onCallBack = onCallBack;
	}
	
	public void modifyName(int patientId, String patientName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", patientId);
		map.put("record_name", patientName);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/rename.do";
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, new ModifyNameHandler());
	}
	
	class ModifyNameHandler extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.modifyNameError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				onCallBack.modifyNameSuccess(responseCode, msg);
			}else{
				onCallBack.modifyNameError(responseCode, msg);
			}
		}
	}
	
	public interface ModifyRecordNameCallBack{
		public void modifyNameSuccess(int code, String msg);
		public void modifyNameError(int code ,String msg);
	}
}
