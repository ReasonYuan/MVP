package com.fq.halcyon.entity.practice;

import java.util.ArrayList;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.halcyon.entity.ItemExam;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

public class StandardExamRecord extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ItemExam mItemExam;
	private ArrayList<ItemExam> itemExamList ;
	
	public void setAtttributeByjson(JSONObject json){
		JSONArray array = json.optJSONArray("examItems");
		ArrayList<JSONObject> tempArray = new ArrayList<JSONObject>();
		for(int i = 0 ; i < array.length(); i++){
			try {
				tempArray.add(array.getJSONObject(i));
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		for(int i = 0 ; i < tempArray.size(); i++){
			this.mItemExam.setItemName(tempArray.get(i).optString("item_name"));
			this.mItemExam.setExpectValue(tempArray.get(i).optString("expect_value"));
			this.mItemExam.setExamValue(tempArray.get(i).optString("exam_value"));
			this.mItemExam.setItemUnit(tempArray.get(i).optString("item_unit"));
			this.mItemExam.setExamId(tempArray.get(i).optInt("id"));
			this.mItemExam.setSample(tempArray.get(i).optString("item_specimen本"));
			itemExamList.add(this.mItemExam);
		}
	}
	public ItemExam getmItemExam() {
		return mItemExam;
	}
	public void setmItemExam(ItemExam mItemExam) {
		this.mItemExam = mItemExam;
	}
	public ArrayList<ItemExam> getItemExamList() {
		return itemExamList;
	}
	public void setItemExamList(ArrayList<ItemExam> itemExamList) {
		this.itemExamList = itemExamList;
	}
}
