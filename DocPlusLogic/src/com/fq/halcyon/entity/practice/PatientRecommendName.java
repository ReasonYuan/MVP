package com.fq.halcyon.entity.practice;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONObject;

/**
 * 病案的系统推荐的名字
 * @author reason
 */
public class PatientRecommendName extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	/**
	 * 病案的名字
	 */
	private String patientName;
	
	/**
	 * 病案的诊断
	 */
	private String patientDiagnose;
	
	public String getPatientName() {
		return patientName;
	}

	public void setPatientName(String patientName) {
		this.patientName = patientName;
	}

	public String getPatientDiagnose() {
		return patientDiagnose;
	}

	public void setPatientDiagnose(String patientDiagnose) {
		this.patientDiagnose = patientDiagnose;
	}

	/***
	 * 判断系统推荐名字是否为空
	 * @return 如果为空返回true，不为空返回false
	 */
	public boolean isEmpty(){
		return "".equals(patientName)&&"".equals(patientDiagnose);
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		patientName = json.optString("patient_name");
		patientDiagnose = json.optString("patient_diagnose");
		patientName = checkNull(patientName);
		patientDiagnose = checkNull(patientDiagnose);
	}
	
}
