package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

/**
 * 随访留言实体类
 * @author wangxi
 *
 */
public class LeaveMessage extends HalcyonEntity{
	private static final long serialVersionUID = 1L;
	/**
	 * 留言时间
	 */
	private String mDate;
	
	/**
	 * 留言姓名
	 */
	private String mName;
	
	/**
	 * 留言信息
	 */
	private String mMessage;
	
	/**
	 * 留言所属人的类型
	 */
	private int roleType;
	
	@Override
	public void test() {
		
	}
	
	public int getRoleType() {
		return roleType;
	}



	public void setRoleType(int roleType) {
		this.roleType = roleType;
	}



	public String getmDate() {
		return mDate;
	}

	public void setmDate(String mDate) {
		this.mDate = mDate;
	}

	public String getmName() {
		return mName;
	}

	public void setmName(String mName) {
		this.mName = mName;
	}

	public String getmMessage() {
		return mMessage;
	}

	public void setmMessage(String mMessage) {
		this.mMessage = mMessage;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.mDate = json.optString("time");
		this.mName = json.optString("name");
		this.mMessage = json.optString("message");
		this.roleType = json.optInt("role_type");
	}
}
