package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class Exam{
	private int id;
	private String examName;
	
	public int getId() {
		return id;
	}

	public String getExamName() {
		return examName;
	}

	public void setAtttributeByjson(JSONObject json){
		this.examName = json.optString("item_name");
		this.id = json.optInt("id");
	}
}
