package com.fq.halcyon.entity;

import java.io.Serializable;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;

public class TimerMember implements Serializable{
	/**
	 * 提醒设置给的哪位成员
	 */
	public int userId;
	public String name;
	
	
//	public String headIcon;

	public void setAtttributeByjson(JSONArray mArray) {
		if(mArray.length() != 0){
			for (int i = 0; i < mArray.length(); i++) {
				JSONObject mObject = mArray.optJSONObject(i);
					this.name = mObject.optString("name");
					this.userId = mObject.optInt("user_id");
//					this.headIcon = mObject.optString("head_icon");
			}
		}else{
			this.name = Constants.getUser().getName();
			this.userId = Constants.getUser().getUserId();
//			this.headIcon = Constants.getUser().getHeadPicPath();
		}
		

	}

	public void setAtttributeByjson(JSONObject mObject) {
//		this.name = mObject.optString("name");
//		this.userId = mObject.optInt("user_id");
//		this.headIcon = mObject.optString("head_icon");
		this.name = Constants.getUser().getName();
		this.userId = Constants.getUser().getUserId();
//		this.headIcon = Constants.getUser().getHeadPicPath();
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

//	public String getHeadIcon() {
//		return headIcon;
//	}
//
//	public void setHeadIcon(String headIcon) {
//		this.headIcon = headIcon;
//	}

}
