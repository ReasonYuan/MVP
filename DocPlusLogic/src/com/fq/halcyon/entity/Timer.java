package com.fq.halcyon.entity;


import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class Timer extends HalcyonEntity{
	
	public void test() {}

	/**
	 * 提醒发送给的哪位成员
	 */
	private TimerMember member;
	
	/**
	 * 提醒id
	 */
	private int id;
	
	/**
	 * 提醒的内容
	 */
	private String timerContent;
	
	/**
	 * 发送提醒的用户的user_id
	 */
	private int userId;
	
	/**
	 * 提醒的时间
	 */
	private long timerDate;
	
	/**
	 * 提醒的留言数
	 */
	private int remarksCount;
	
	
	public TimerMember getTimerMember() {
		return member;
	}

	public void setTimerMember(TimerMember timerMember) {
		this.member = timerMember;
	}

	public int getTimerId() {
		return id;
	}

	public void setTimerId(int id) {
		this.id = id;
	}

	public String getTimerContent() {
		return timerContent;
	}

	public void setTimerContent(String timerContent) {
		this.timerContent = timerContent;
	}

	public int getSendUserId() {
		return userId;
	}

	public void setSendUserId(int userId) {
		this.userId = userId;
	}

	public long getTimerDate() {
		return timerDate;
	}

	public void setTimerDate(long timerDate) {
		this.timerDate = timerDate;
	}

	public int getRemarksCount() {
		return remarksCount;
	}

	public void setRemarksCount(int remarksCount) {
		this.remarksCount = remarksCount;
	}
	
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.id = json.optInt("id");
		this.userId = json.optInt("userId");
		this.timerDate = json.optLong("timer_date");
		this.timerContent = json.optString("timer_content");
		this.remarksCount = json.optInt("remarks_count");
		try {
			JSONArray mArray = json.optJSONArray("member");	
			this.member = new TimerMember();
			if(mArray != null){
				member.setAtttributeByjson(mArray);
			}
//			else{
//				JSONObject mObject = json.optJSONObject("member");
//				this.member = new TimerMember();
//				member.setAtttributeByjson(mObject);
//			}
		} catch (Exception e) {
//			JSONObject mObject = json.optJSONObject("member");
//			this.member = new TimerMember();
//			if(mObject != null){
//				member.setAtttributeByjson(mObject);
//			}
			e.printStackTrace();
		}
	}
	
}
