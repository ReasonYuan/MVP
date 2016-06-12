package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.SurveyRecordItem;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.JsonHelper;
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
public class SurveyRecordLogic {

	private SurveyRecordCallBack onCallBack;
	private ArrayList<SurveyRecordItem> surItemList;
	
	public SurveyRecordLogic(SurveyRecordCallBack onCallBack) {
		this.onCallBack = onCallBack;
		surItemList = new ArrayList<SurveyRecordItem>();
	}
	
	public interface SurveyRecordCallBack{
		public void onSurveyError(int code, String msg);
		public void onSurveyResult(int code, ArrayList<SurveyRecordItem> surItemList);
	}
	
	public void surveyRecord(final int recordId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", recordId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/over_view_record.do";
//		String uri = "http://192.168.3.101:8081/yiyi/test/survey_record.do";
		HalcyonHttpResponseHandle mHandle = new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				onCallBack.onSurveyError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (responseCode == 0 && type == 1) {
					JSONObject jsonObj = (JSONObject) results;
					Iterator<String> keys = jsonObj.keys();
					while (keys.hasNext()) {
						String key = keys.next();
						String value = jsonObj.optString(key);
						SurveyRecordItem item = new SurveyRecordItem();
						item.setName(key);
						item.setContent(value);
						surItemList.add(item);
					}
					FileHelper.saveFile(results.toString(), FileSystem.getInstance().getUserCachePath()+recordId+"record.survey", true);
					onCallBack.onSurveyResult(responseCode, surItemList);
				}else{
					onCallBack.onSurveyError(responseCode, msg);
				}
			}
		};
		if(Platform.isNetWorkConnect){
			ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		}else{
			String cache = FileHelper.readString(FileSystem.getInstance().getUserCachePath()+recordId+"record.survey", true);
			if(cache != null && !cache.equals("")){
				try {
					mHandle.handle(0, cache, 1, new JSONObject(cache));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}else {
				ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
			}
		}
	}
}
