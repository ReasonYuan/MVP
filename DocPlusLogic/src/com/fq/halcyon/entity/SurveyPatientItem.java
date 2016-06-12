package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class SurveyPatientItem extends HalcyonEntity{
	private static final long serialVersionUID = 1L;

	private String patientName;
	private String tentativeDiag;
	public String getPatientName() {
		return patientName;
	}
	public void setPatientName(String patientName) {
		this.patientName = patientName;
	}
	public String getTentativeDiag() {
		return tentativeDiag;
	}
	public void setTentativeDiag(String tentativeDiag) {
		this.tentativeDiag = tentativeDiag;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.patientName = json.optString("record_name");
		this.tentativeDiag = json.optString("tentative_diagnosiss");
	}
}
