package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;


public class Hospital extends HalcyonEntity{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int id;
	public int getHospitalId() {
		return id;
	}
	public void setHospitalId(int hospitalId) {
		this.id = hospitalId;
	}
	
	@Override
	public void test() {
		
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.id = json.optInt("id");
	}
}
