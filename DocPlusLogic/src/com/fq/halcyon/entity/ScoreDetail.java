package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

/**
 *积分获取详细的实体类 
 */
public class ScoreDetail extends HalcyonEntity{

	private int score; //本次操作的积分
	private long date; //本次操作的时间
	private String ctrlName;//本次做的什么操作
	public int getScore() {
		return score;
	}
	public void setScore(int score) {
		this.score = score;
	}
	public long getDate() {
		return date;
	}
	public void setDate(long date) {
		this.date = date;
	}
	public String getCtrlName() {
		return ctrlName;
	}
	public void setCtrlName(String ctrlName) {
		this.ctrlName = ctrlName;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		date = json.optLong("date");
		ctrlName = json.optString("action");
		score = json.optInt("expense");
		super.setAtttributeByjson(json);
	}
	
	@Override
	public void test() {
		
	}
	
	
}
