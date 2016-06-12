package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class FollowUpTemple extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 模板的名称
	 */
	private String TempleName;
	
	/**
	 * 模板拥有者ID
	 */
	private int userId;
	
	/**
	 * 随访时间
	 */
	private ArrayList<OnceFollowUpCycle> mArrayList;
	
	/**
	 *模板ID
	 */
	private int mTempleId;
	
	
	public String getTempleName() {
		return TempleName;
	}

	public void setTempleName(String templeName) {
		TempleName = templeName;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public ArrayList<OnceFollowUpCycle> getmArrayList() {
		return mArrayList;
	}

	public void setmArrayList(ArrayList<OnceFollowUpCycle> mArrayList) {
		this.mArrayList = mArrayList;
	}
	
	public int getmTempleId() {
		return mTempleId;
	}

	public void setmTempleId(int mTempleId) {
		this.mTempleId = mTempleId;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.TempleName = json.optString("followup_template_name");
		this.userId = json.optInt("user_id");
		JSONArray mArray = json.optJSONArray("followup_template_items");
		this.mTempleId = json.optInt("followup_template_id");
		mArrayList = new ArrayList<OnceFollowUpCycle>();
		if(mArray != null && mArray.length() != 0){
			for (int i = 0; i < mArray.length(); i++) {
				OnceFollowUpCycle mCycle = new OnceFollowUpCycle();
				mCycle.setAtttributeByjson(mArray.optJSONObject(i));
				mArrayList.add(mCycle);
			}
		}
		
	}
	
	@Override
	public void test() {
		
	}

}
