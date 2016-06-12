package com.fq.halcyon.entity;

import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

public class ChatUserInfo extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * userinfo中保存单个聊天用户的imageId
	 */
	private int imageId;
	
	/**
	 * 保存用户的name
	 */
	private String name;
	
	/**
	 * 聊天类型 1:单聊 2:群聊
	 */
	private int chatType;
	
	/**
	 * 单聊IMSDK用户ID
	 * 
	 */
	private String customUserId;
	
	/**
	 * 
	 *群聊IMSDK 群id
	 *
	 */
	private String groupId;
	

	/**
	 * 最后一条内容
	 *
	 */
	private String lastMessage;
	
	/**
	 * 
	 *最后一条内容的时间
	 */
	private double mSendTime;
	
	
	
	public double getmSendTime() {
		return mSendTime;
	}

	public void setmSendTime(double mSendTime) {
		this.mSendTime = mSendTime;
	}

	public String getLastMessage() {
		return lastMessage;
	}

	public void setLastMessage(String lastMessage) {
		this.lastMessage = lastMessage;
	}

	public String getCustomUserId() {
		return customUserId;
	}

	public void setCustomUserId(String customUserId) {
		this.customUserId = customUserId;
	}

	public String getGroupId() {
		return groupId;
	}

	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}

	public int getChatType() {
		return chatType;
	}

	public void setChatType(int chatType) {
		this.chatType = chatType;
	}

	public int getImageId() {
		return imageId;
	}

	public void setImageId(int imageId) {
		this.imageId = imageId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.imageId = json.optInt("imageId");
		this.name = json.optString("name");
		this.customUserId = json.optString("customUserId");
		this.groupId = json.optString("groupId");
		this.chatType = json.optInt("chatType");
		this.lastMessage = json.optString("lastMessage");
		this.mSendTime = json.optDouble("mSendTime");
	}
	
	public void setAtttributeByjsonString(String json){
		try {
			String decode = new String(json.getBytes(), "UTF-8");
			JSONObject jsonObject = new JSONObject(decode);
			setAtttributeByjson(jsonObject);
		} catch (Exception e) {
			try {
				System.out.println(new String(json.getBytes(), "UTF-8"));
			} catch (Exception e2) {
			}
			e.printStackTrace();
		}
	}
	
	@Override
	public String toString() {
		JSONObject json = new JSONObject();
		try {
			json.put("imageId", imageId);
			json.put("name", name);
			json.put("customUserId", customUserId);
			json.put("groupId", groupId);
			json.put("chatType", chatType);
			json.put("lastMessage", lastMessage);
			json.put("mSendTime", mSendTime);
			return json.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return super.toString();
	}
}
