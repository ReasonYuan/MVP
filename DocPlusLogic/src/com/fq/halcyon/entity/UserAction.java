package com.fq.halcyon.entity;

import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.TimeFormatUtils;

public class UserAction {

	/**注册*/
	public static final int ACTION_REGIST = 0;
	/**上传病历*/
	public static final int ACTION_UP_RECORD = 1;
	/**添加病人*/
	public static final int ACTION_ADD_PATIENT = 2;
	/**添加医生*/
	public static final int ACTION_ADD_DEOCTOR = 3;
	/**设置提醒*/
	public static final int ACTION_SET_TIMER = 4;
	/**提醒留言*/
	public static final int ACTION_ADD_REMARK = 5;
	/**查看过的患者*/
	public static final int ACTION_VIEW_PATIENT = 6;

	private String[] actions = {"注册","上传病历","添加病人","添加医生","设置提醒","提醒留言","看过患者"};
	
	
	private long date;
	//private String dateStr;
	private int action;
	private String des;
	
	public UserAction(){}
	
	public UserAction(long date,int action,String des){
		this.date = date;
		this.action = action;
		this.des = des;
	}
	
	public long getDate() {
		return date;
	}
	public void setDate(long date) {
		this.date = date;
	}
	public String getDateStr() {
		return TimeFormatUtils.getTimeByFormat(date, "MM/dd");
	}
	/*public void setDateStr(String dateStr) {
		this.dateStr = dateStr;
	}*/
	public String getActionStr() {
		return actions[action];
	}
	public int getAction() {
		return action;
	}
	public void setAction(int action) {
		this.action = action;
	}
	public String getDes() {
		return des;
	}
	public void setDes(String des) {
		this.des = des;
	}

	public void setAtttributeByjson(JSONObject json){
		this.date = json.optLong("date");
		this.action = json.optInt("action");
		this.des = json.optString("des");
	}
	
	public JSONObject getJson(){
		JSONObject obj = new JSONObject();
		try {
			obj.put("date", date);
			obj.put("action", action);
			obj.put("des", des);
			return obj;
		} catch (JSONException e) {
			e.printStackTrace();
			return null;
		}
	}
}

