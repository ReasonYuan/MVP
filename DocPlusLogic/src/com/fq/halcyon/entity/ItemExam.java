package com.fq.halcyon.entity;

import com.fq.halcyon.entity.RecordItem.EXAM_STATE;
import com.fq.lib.json.JSONObject;

public class ItemExam {
	private String abn;
	private EXAM_STATE state;
	private String itemName;
	private String sample;
	public String getSample() {
		return sample;
	}



	public void setSample(String sample) {
		this.sample = sample;
	}



	public String getItemName() {
		return itemName;
	}



	public void setItemName(String itemName) {
		this.itemName = itemName;
	}


	/**
	 * 图表的时间，格式yyyy-MM-dd
	 */
	private String dealTime;
	public String getDealTime() {
		return dealTime;
	}

	
	public String getYear(){
		if(dealTime != null && !(dealTime.equals(""))){
			return dealTime.substring(2, 4);
		}
		return "";
	}


	public String getMonth(){
		if(dealTime != null && !(dealTime.equals(""))){
			return (dealTime.substring(5, 7)).replaceAll("^(0+)", "");
		}
		return "";
	}
	
	public String getDay(){
		if(dealTime != null && !(dealTime.equals(""))){
			return (dealTime.substring(8, 10)).replaceAll("^(0+)", "");
		}
		return "不详";
	}
	
	public String getOneDay(){
		if(dealTime != null && !(dealTime.equals(""))){
			return (dealTime.substring(8, 10)).replaceAll("^(0+)", "") ;
		}
		return "不详";
	}
	
	private String expectValue;
	public String getExpectValue() {
		return expectValue;
	}

	public void setExpectValue(String expectValue) {
		this.expectValue = expectValue;
	}



	private String examValue;
	public String getExamValue() {
		return examValue;
	}



	public void setExamValue(String examValue) {
		this.examValue = examValue;
	}



	private String itemUnit;
	public String getItemUnit() {
		return itemUnit;
	}



	public void setItemUnit(String itemUnit) {
		this.itemUnit = itemUnit;
	}



	private int examId;
	
	
	
	public int getExamId() {
		return examId;
	}


	public void setExamId(int examId) {
		this.examId = examId;
	}
	
	public String getAbn() {
		return abn;
	}



	public void setAbn(String abn) {
		this.abn = abn;
	}

	public void setAtttributeByjson(JSONObject json){
		this.itemName = json.optString("item_name");
		this.examId = json.optInt("exam_id");
		this.itemUnit = json.optString("item_unit");
		this.examValue = json.optString("exam_value");
		this.expectValue = json.optString("expect_value");
		this.dealTime = json.optString("deal_time");
		this.abn = json.optString("abnormal_value");
		this.sample = json.optString("item_specimen");
		if("L".equals(abn))setState(EXAM_STATE.L);
		else if("H".equals(abn))setState(EXAM_STATE.H);
		else setState(EXAM_STATE.M);
	}



	public EXAM_STATE getState() {
		return state;
	}



	public void setState(EXAM_STATE state) {
		this.state = state;
	}

}