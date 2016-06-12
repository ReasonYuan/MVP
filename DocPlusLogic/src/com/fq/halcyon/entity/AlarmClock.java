package com.fq.halcyon.entity;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.lib.json.JSONObject;

/**
 * 闹钟 ( 某用户未来的提醒 )
 */
public class AlarmClock extends HalcyonEntity {

	private String timerContent; // 提醒内容
	private int userId;
	private int timerId;
	private long timerDate; // 提醒的时间

	/**
	 * 提醒时间列表
	 * 
	 */
	
	private HashMap<Integer, Long> mTimeHashMap;
	
	
	private ArrayList<Long> timerList;
	
	public ArrayList<Long> getTimerList() {
		return timerList;
	}
	
	public HashMap<Integer, Long> getmTimeHashMap() {
		return mTimeHashMap;
	}

	public void setmTimeHashMap(HashMap<Integer, Long> mTimeHashMap) {
		this.mTimeHashMap = mTimeHashMap;
	}



	public void setTimerList(ArrayList<Long> timerList) {
		this.timerList = timerList;
	}

	public String getTimerContent() {
		return timerContent;
	}

	public void setTimerContent(String timerContent) {
		this.timerContent = timerContent;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getTimerId() {
		return timerId;
	}

	public void setTimerId(int timerId) {
		this.timerId = timerId;
	}

	public long getTimerDate() {
		return timerDate;
	}

	public void setTimerDate(long timerDate) {
		this.timerDate = timerDate;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.timerId = json.optInt("id");
		this.userId = json.optInt("userId");
		this.timerDate = json.optInt("timer_date");
		this.timerContent = json.optString("timer_content");
		super.setAtttributeByjson(json);
	}
	
	@Override
	public void test() {
	}

}
