package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

/**
 * 病人实体类
 * @author wangxi
 *
 */
public class PatientFriend extends Contacts{
	private static final long serialVersionUID = 1L;
	private String headPath;
	private String patientFriendGender;
	private String name;
	private String description;
	/**
	 * 病案id
	 */
	private int patientId;
	/**
	 * 病案名称
	 * @return
	 */
	private String patientName;
	
	public String getPatientName() {
		return patientName;
	}
	public void setPatientName(String patientName) {
		this.patientName = patientName;
	}
	public String getHeadPath() {
		return headPath;
	}
	public void setHeadPath(String headPath) {
		this.headPath = headPath;
	}
	
	public String getPatientFriendGender() {
		return patientFriendGender;
	}
	public void setPatientFriendGender(String patientFriendGender) {
		this.patientFriendGender = patientFriendGender;
	}
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public int getPatientId() {
		return patientId;
	}
	public void setPatientId(int patientId) {
		this.patientId = patientId;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.name = json.optString("name");
		this.patientFriendGender = json.optString("gender");
		this.description = json.optString("description");
		this.patientId = json.optInt("patient_id");
		this.headPath  = json.optString("image_path");
		this.patientName = json.optString("patient_name");
	}
}
