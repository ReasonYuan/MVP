package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

/**
 * 首页的一个数据（随访）
 * 
 * @author reason
 */
public class HomeData extends HalcyonEntity {

	protected static final int READ_STATE_NO = 0;
	public static final int READ_STATE_YES = 1;

	private static final long serialVersionUID = 1L;

	/**
	 * 随访的Id
	 */
	private int mFollowUpId;
	/**
	 * 随访用户的头像地址
	 */
	private String mImgPath;
	/**
	 * 随访用户的头像ID
	 */
	private int mImgID;
	/**
	 * 这个随访是否已经读过
	 */
	private int mReadFlag;

	/**
	 * 随访的名称
	 */
	private String mFollowUpName;

	/**
	 * 随访人的名称
	 */
	private String mPatientName;

	public String getmFollowUpName() {
		return mFollowUpName;
	}

	public void setmFollowUpName(String mFollowUpName) {
		this.mFollowUpName = mFollowUpName;
	}

	public String getmPatientName() {
		return mPatientName;
	}

	public void setmPatientName(String mPatientName) {
		this.mPatientName = mPatientName;
	}

	public int getmFollowUpId() {
		return mFollowUpId;
	}

	public void setmFollowUpId(int mFollowUpId) {
		this.mFollowUpId = mFollowUpId;
	}

	public String getmImgPath() {
		return mImgPath;
	}

	public void setmImgPath(String mImgPath) {
		this.mImgPath = mImgPath;
	}
	
	public int getmImgID() {
		return mImgID;
	}

	public void setmImgID(int mImgID) {
		this.mImgID = mImgID;
	}

	public boolean isRead() {
		return mReadFlag == READ_STATE_YES;
	}

	public void setRead(int readFlag) {
		this.mReadFlag = readFlag;
	}

	/*
	 * public void setRead(boolean isRead) { this.mIsRead = isRead; }
	 */

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.mFollowUpId = json.optInt("timer_id");
		this.mImgPath = json.optString("image_path");
		this.mImgID = json.optInt("image_id");
		mReadFlag = json.optInt("read_flag");
		this.mFollowUpName = json.optString("followup_name");
		this.mPatientName = json.optString("name");
	}

	@Override
	public JSONObject getJson() {
		return super.getJson();
	}
}
