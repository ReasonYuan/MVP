package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONObject;


public class Tag extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int tag_id; 
	private int count;
	private String title;

	private ArrayList<Contacts> mUser;
	
	public int getId() {
		return tag_id;
	}

	public void setId(int id) {
		this.tag_id = id;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public String getTitle(){
		return this.title;
	}
	
	public String getName(){
		return getTitle();
	}
	
	public void setTitle(String title){
		this.title = title;
	}
	
	@Override
	public void test() {
		
	}
	
	public void setContacts(ArrayList<Contacts> user){
		mUser = user;
	}
	
	public ArrayList<Contacts> getContacts(){
		if(mUser == null)mUser = new ArrayList<Contacts>();
		return mUser;
	}
	
	public void addContacts(Contacts user){
		if(user == null)return;
		if(mUser == null)mUser = new ArrayList<Contacts>();
		if(!mUser.contains(user))mUser.add(user);
	}
	
	public void removeContacts(Contacts user){
		if(mUser == null || user == null)return;
		if(mUser.contains(user))mUser.remove(user);
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.tag_id = json.optInt("tag_id");
		this.count = json.optInt("count");
		this.title = json.optString("title");
	}
}
