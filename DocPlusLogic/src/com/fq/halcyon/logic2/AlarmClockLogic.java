package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.AlarmClock;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

/**
 * 获取某用户未来的所有提醒 
 */
public class AlarmClockLogic {

	private List<AlarmClock> mClockList = new ArrayList<AlarmClock>();
	public interface AlarmClockLogicCallBack{
		public void onErrorCallBack(int code, String msg);
		public void onResultCallBack(int code);
	} 
	
	public AlarmClockLogicCallBack onCallBack; 
	
	public AlarmClockLogicHandle mHandle = new AlarmClockLogicHandle();
	
	public AlarmClockLogic(final AlarmClockLogicCallBack onCallBack) {
		this.onCallBack = onCallBack;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/timer/my_timers_future.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public class AlarmClockLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			if(Constants.alarms == null) Constants.alarms = new ArrayList<AlarmClock>();
			onCallBack.onErrorCallBack(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				if(Constants.alarms == null){
					Constants.alarms = new ArrayList<AlarmClock>();
				}
				JSONObject jsonObj = (JSONObject) results;
				try {
					JSONArray jsonArray = jsonObj.getJSONArray("timers");
					int count = jsonArray.length();
					Constants.alarms.clear();
					for (int i = 0; i < count; i++) {
						AlarmClock alarmClock = new AlarmClock();
						alarmClock.setAtttributeByjson(jsonArray.getJSONObject(i));
						Constants.alarms.add(alarmClock);
					}
					onCallBack.onResultCallBack(responseCode);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}else{
				if(Constants.alarms == null) Constants.alarms = new ArrayList<AlarmClock>();
			}
		}
	}
	
	
}
