package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class Medicine extends HalcyonEntity {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int id;
	private String name;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getMedicineId() {
		return id;
	}

	public void setMedicineId(int hospitalId) {
		this.id = hospitalId;
	}

	@Override
	public void test() {

	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.id = json.optInt("id");
		this.name = json.optString("name");
	}
}
