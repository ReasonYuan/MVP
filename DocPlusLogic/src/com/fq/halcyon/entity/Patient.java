package com.fq.halcyon.entity;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

/**
 * 病案的实体类
 */
public class Patient extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * 病案ID
	 */
	private int medicalId;
	/**
	 * 病案名称
	 */
	private String medicalName;
	/**
	 * 病案来源类型，eg. 自己上传，分享 etc.
	 */
	private int medicalFromType;
	/**
	 * 病历来源，eg. XX分享
	 */
	private String medicalFrom;
	/**
	 * 病案创建时间 
	 */
	private String createTime;
	/**
	 * 病历数
	 */
	private int recordCount;
	/**
	 * 未识别病历数
	 */
	private int notRecCount;
	/**
	 * 分享人的类型
	 */
	private int fromUserType;
	
	public int getMedicalId() {
		return medicalId;
	}

	public void setMedicalId(int medicalId) {
		this.medicalId = medicalId;
	}

	public String getMedicalName() {
		return medicalName;
	}

	public void setMedicalName(String medicalName) {
		this.medicalName = medicalName;
	}

	public int getMedicalFromType() {
		return medicalFromType;
	}

	public void setMedicalFromType(int medicalFromType) {
		this.medicalFromType = medicalFromType;
	}

	public String getMedicalFrom() {
		return medicalFrom == null?"":medicalFrom;
	}

	public void setMedicalFrom(String medicalFrom) {
		this.medicalFrom = medicalFrom;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public int getRecordCount() {
		return recordCount;
	}

	public void setRecordCount(int recordCount) {
		this.recordCount = recordCount;
	}

	public int getNotRecCount() {
		return notRecCount;
	}

	public void setNotRecCount(int notRecCount) {
		this.notRecCount = notRecCount;
	}
	
	public int getFromUserType() {
		return fromUserType;
	}

	public void setFromUserType(int fromUserType) {
		this.fromUserType = fromUserType;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.medicalId = json.optInt("patient_id");
		this.createTime = json.optString("create_time");
		this.medicalName = json.optString("patient_name");
		this.medicalFromType = json.optInt("source_from");
		this.recordCount = json.optInt("record_count");
		this.notRecCount = json.optInt("unrecong_count");
		JSONArray jsonArr = json.optJSONArray("patient_from");
		if (jsonArr != null) {
			for (int i = 0; i < jsonArr.length(); i++) {
				JSONObject obj = jsonArr.optJSONObject(0);
				this.medicalFrom = obj.optString("name");
				this.fromUserType = obj.optInt("role_type");
			}
		}
		
	}
	
	@Override
	public void test() {
		
	}	
}
