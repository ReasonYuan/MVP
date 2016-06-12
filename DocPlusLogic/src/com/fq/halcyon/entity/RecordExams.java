package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class RecordExams extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private ArrayList<ExamDate> items;
	
	private String item_name;
	
	private int doctorPatientId;
	
	
	
	public String getName(){
		return this.item_name;
	}
	
	public int getDocPatientId(){
		return this.doctorPatientId;
	}
	
	public ArrayList<ExamDate> getEXamDates(){
		return this.items;
	}
	
	public class ExamDate extends HalcyonEntity{
		
		private String exam_date;
		private String item_value;

		public String getDate(){
			return this.exam_date;
		}
		
		public String getValue(){
			return this.item_value;
		}
		
		@Override
		public void test() {
			
		}
		@Override
		public void setAtttributeByjson(JSONObject json){
			super.setAtttributeByjson(json);
			this.exam_date = json.optString("exam_date");
			this.item_value = json.optString("item_value");
		}
	}
	
	@Override
	public void test() {
		
	}
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.doctorPatientId = json.optInt("doctorPatientId");
		this.item_name = json.optString("item_name");
		JSONArray itemsArray = json.optJSONArray("items");
		if(itemsArray != null){
			items = new ArrayList<RecordExams.ExamDate>();
			for (int i = 0; i < itemsArray.length(); i++) {
				ExamDate date = new ExamDate();
				date.setAtttributeByjson(itemsArray.optJSONObject(i));
				items.add(date);
			}
		}
	}
}
