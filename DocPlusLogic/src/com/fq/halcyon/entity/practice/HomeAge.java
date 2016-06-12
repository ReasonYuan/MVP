package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class HomeAge extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private int totalPatientCount = 0;
	private ArrayList<String> ageList = new ArrayList<String>();
	private HashMap<String, Integer> ageMap = new HashMap<String, Integer>();
	public int getTotalPatientCount() {
		return totalPatientCount;
	}
	public void setTotalPatientCount(int totalPatientCount) {
		this.totalPatientCount = totalPatientCount;
	}
	public ArrayList<String> getAgeList() {
		return ageList;
	}
	public void setAgeList(ArrayList<String> ageList) {
		this.ageList = ageList;
	}
	public HashMap<String, Integer> getAgeMap() {
		return ageMap;
	}
	public void setAgeMap(HashMap<String, Integer> ageMap) {
		this.ageMap = ageMap;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		totalPatientCount = json.optInt("total_patient_count");
		
		JSONArray jsonArray = json.optJSONArray("age_scope_count");
		int count = jsonArray.length();
		for(int i = 0 ; i < count ; i++) {
			JSONObject obj = jsonArray.optJSONObject(i);
			Iterator<String> iterator = obj.keys();
			while(iterator.hasNext()) {
				String key = iterator.next();
				ageList.add(key);
				ageMap.put(key, obj.optInt(key));
			}
		}
	}
}
