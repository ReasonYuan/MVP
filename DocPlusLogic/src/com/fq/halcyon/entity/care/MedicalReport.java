package com.fq.halcyon.entity.care;

import java.util.ArrayList;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

/***
 * Care用户体检报告的实体类
 * @author reason
 */
public class MedicalReport extends HalcyonEntity{
	
	private static final long serialVersionUID = 1L;

	/**体检的时间*/
	private String checkTime;
	
	/**体检的总体评分*/
	private String overallScore;
	
	/**体检的病案id*/
//	private int patientId;
	
	/**检查综合诊断的info_id*/
	private int overallInfoId;
	
	/**检查下检查项目的列表*/
	private ArrayList<MedicalItem> medicalItems = new ArrayList<MedicalItem>();

	public String getCheckTime() {
		return checkTime;
	}

	public void setCheckTime(String checkTime) {
		this.checkTime = checkTime;
	}

	public String getOverallScore() {
		return overallScore;
	}

	public void setOverallScore(String overallScore) {
		this.overallScore = overallScore;
	}

//	public int getPatientId() {
//		return patientId;
//	}
//
//	public void setPatientId(int patientId) {
//		this.patientId = patientId;
//	}

	public int getOverallInfoId() {
		return overallInfoId;
	}

	public void setOverallInfoId(int overallInfoId) {
		this.overallInfoId = overallInfoId;
	}

	public ArrayList<MedicalItem> getMedicalItems() {
		return medicalItems;
	}

	public void setMedicalItems(ArrayList<MedicalItem> medicalItems) {
		this.medicalItems = medicalItems;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
//		super.setAtttributeByjson(json);
		
		this.overallInfoId = json.optInt("overall_info_id");
		this.checkTime = checkNull(json.optString("check_at"));
		this.overallScore = checkNull(json.optString("overall_score"));
		
		JSONArray array = json.optJSONArray("exam_infos");
		medicalItems.clear();
		for(int i = 0; i < array.length(); i++){
			JSONObject obj = array.optJSONObject(i);
			MedicalItem item = new MedicalItem();
			item.setAtttributeByjson(obj);
			medicalItems.add(item);
		}
	}
}
