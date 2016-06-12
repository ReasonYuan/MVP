package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

public class Contacts extends Person {

	private static final long serialVersionUID = 1L;
	
	private boolean is_friend;
	private ArrayList<String> mTags;
	private int userFriendId;
	private int relationId;
	private String requestMsg;
	
	/**
	 * 好友的来源
	 */
	private String source;
	private int status;// 添加好友的状态 0是等待处理

	
	public String getSource() {
		if(source == null || "".equals(source))return "账号查询";
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public int getUserFriendId(){
		return userFriendId;
	}
	
	public String getRequestMsg(){
		return requestMsg;
	}
	
	public void setTags(ArrayList<String> tags) {
		mTags = tags;
	}

	public ArrayList<String> getTags() {
		if(mTags == null)mTags = new ArrayList<String>();
		return mTags;
	}

	public void addTag(String tag) {
		if (tag == null || "".equals(tag))
			return;
		if (mTags == null) {
			mTags = new ArrayList<String>();
			mTags.add(tag);
		} else {
			boolean ishave = false;
			for (String tg : mTags) {
				if (tag.equals(tg)) {
					ishave = true;
					break;
				}
			}
			if (!ishave)
				mTags.add(tag);
		}
	}

	public void removeTag(String tag) {
		if (tag == null || "".equals(tag))
			return;
		if (mTags == null)
			return;
		for (String tg : mTags) {
			if (tag.equals(tg)) {
				mTags.remove(tg);
				break;
			}
		}
	}

	public boolean isFriend() {
		return is_friend;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}
	
	public void setRelationId(int relationId){
		this.relationId = relationId;
	}
	
	public int getRelationId(){
		return this.relationId;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.is_friend = json.optBoolean("is_friend", false);
		this.status = json.optInt("status", -1);
		this.userFriendId = json.optInt("userFriendId");
		this.source = json.optString("source");
		this.relationId = json.optInt("user_doctor_relation_id");
		this.requestMsg = json.optString("request_message");
		
		JSONArray tags = json.optJSONArray("tags");
		if(tags != null){
			mTags = new ArrayList<String>();
			for(int i = 0;i < tags.length(); i++){
				JSONObject tagJson = tags.optJSONObject(i);
				mTags.add(tagJson.optString("title"));
			}
		}
	}

	@Override
	public JSONObject getJson() {
		JSONObject json = super.getJson();
		try {
			json.put("is_friend", is_friend);
			json.put("status", status);
			json.put("userFriendId", userFriendId);
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json;
	}
	
}
