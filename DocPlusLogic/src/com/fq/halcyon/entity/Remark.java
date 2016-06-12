package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class Remark extends HalcyonEntity{

	/**
	 * 留言的Id
	 */
	private int id;
	/**
	 * 这条留言发送的时间
	 */
	private long remarkDate;
	/**
	 * 这条留言的内容
	 */
	private String remark;
	/**
	 * 这条留言所属提醒的id
	 */
	private int timeId;
	
	/**
	 *该条留言的用户id 
	 */
	private int userId;
	
	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public long getRemarkDate() {
		return remarkDate;
	}


	public void setRemarkDate(long remarkDate) {
		this.remarkDate = remarkDate;
	}


	public String getRemarks() {
		return remark;
	}


	public void setRemarks(String remarks) {
		this.remark = remarks;
	}


	public int getTimeId() {
		return timeId;
	}


	public void setTimeId(int timeId) {
		this.timeId = timeId;
	}
	
	public int getUserId() {
		return userId;
	}


	public void setUserId(int userId) {
		this.userId = userId;
	}


	public void test() {}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.id = json.optInt("id");
		this.timeId = json.optInt("timer_id");
		this.remarkDate = json.optLong("remark_date");
		this.remark = json.optString("remarks");
		this.userId = json.optInt("user_id");
	}
}
