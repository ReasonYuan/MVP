package com.fq.halcyon.entity.practice;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.CareConstants;

public class MyRelationship extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	/**
	 * 成员ID
	 */
	private int patientId;
	/**
	 * 成员姓名
	 */
	private String relName;
	/**
	 * 成员关系ID
	 */
	private int identityId;
	
	public int getPatientId() {
		return patientId;
	}
	public void setPatientId(int patientId) {
		this.patientId = patientId;
	}
	public String getRelName() {
		return relName;
	}
	public void setRelName(String relName) {
		this.relName = relName;
	}
	public int getIdentityId() {
		return identityId;
	}
	public void setIdentityId(int identityId) {
		this.identityId = identityId;
	}
	/**
	 * 获取成员关系
	 * @return String
	 */
	public String getRelationship() {
		return CareConstants.getRelationByType(identityId);
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.relName = json.optString("name");
		this.patientId = json.optInt("patient_id");
		this.identityId = json.optInt("identity_id");
	}
}
