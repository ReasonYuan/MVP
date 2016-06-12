package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class OnceFollowUpCycle extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 随访内容
	 */
	private String mItemName;
	
	/**
	 * 随访项值
	 */
	private String mItentValue;
	
	/**
	 * 随访项单位
	 */
	private String mItemUnit;
	
	
	/**
	 * 关联前项ID
	 */
	private String mPreId;
	
	/**
	 * ItemId
	 */
	private int mItemtId;
	
	/**
	 * 每次随访的时间
	 */
	private String mTimerDate;
	
	@Override
	public void test() {
		
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.mItemName = json.optString("item_name");
		this.mItentValue = json.optString("item_value");
		this.mItemUnit = json.optString("item_unit");
		this.mPreId = json.optString("pre_id");
		this.mItemtId = json.optInt("item_id");
		this.mTimerDate = json.optString("timer_date");
	}

	public String getmItemName() {
		return mItemName;
	}

	public void setmItemName(String mItemName) {
		this.mItemName = mItemName;
	}

	public String getmItentValue() {
		return mItentValue;
	}

	public void setmItentValue(String mItentValue) {
		this.mItentValue = mItentValue;
	}

	public String getmItemUnit() {
		return mItemUnit;
	}

	public void setmItemUnit(String mItemUnit) {
		this.mItemUnit = parseDate(mItemUnit);
	}

	public String getmPreId() {
		return mPreId;
	}

	public void setmPreId(String mPreId) {
		this.mPreId = mPreId;
	}

	public int getmItemtId() {
		return mItemtId;
	}

	public void setmItemtId(int mItemtId) {
		this.mItemtId = mItemtId;
	}
	
	
	public String getmTimerDate() {
		return mTimerDate;
	}

	public void setmTimerDate(String mTimerDate) {
		this.mTimerDate = mTimerDate;
	}

	public String parseDate(String str){
		String tmp = null;
		if (str.equals("天")) {
			tmp = "day";
		}else if (str.equals("月")) {
			tmp = "month";
		}else if (str.equals("周")) {
			tmp = "week";
		}else if (str.equals("年")) {
			tmp = "year";
		}
		return tmp;
	}
}
