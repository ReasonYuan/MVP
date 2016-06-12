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

public class DelRecordLogic {

	private DelRecordFolderCallBack onCallBack;
	private DelRecordFolderHandle mHandle;
	
	public interface DelRecordFolderCallBack{
		public void onDelFolderError(int code, String msg);
		public void onDelFolderSuccess(int code, String msg);
	}
	
	public DelRecordLogic(final DelRecordFolderCallBack onCallBack) {
		this.onCallBack = onCallBack;
		this.mHandle = new DelRecordFolderHandle();
	}
	
	public void delRecordFolder(int recordId) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", recordId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/delete.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	class DelRecordFolderHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onDelFolderError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				onCallBack.onDelFolderSuccess(responseCode, msg);
			}else{
				onCallBack.onDelFolderError(responseCode, msg);
			}
		}
	}
}
