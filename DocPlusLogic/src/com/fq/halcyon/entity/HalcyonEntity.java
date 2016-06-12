package com.fq.halcyon.entity;

import java.io.Serializable;

import com.fq.lib.ChinesetSortHelper;
import com.fq.lib.json.JSONObject;

public abstract class HalcyonEntity implements Serializable,  Comparable<HalcyonEntity>{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 2L;
	
	protected String name;
	
	protected String pinyinName = "";
	
	public String getName() {
		return name==null?"":name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPinyinName() {
		if(pinyinName == null || "".equals(pinyinName)){//
			pinyinName = ChinesetSortHelper.getPingYin(getName());//.toUpperCase();
		}
		return pinyinName;
	}

	public void setPinyinName(String pinyinName) {
		this.pinyinName = pinyinName;
	}

	@Override
	public int compareTo(HalcyonEntity user) {
		if(this == user)return 0;
		else if(user == null) return 1;
		else{
			return pinyinName.compareTo(user.pinyinName);
		}
	}
	
//	public abstract void test();
	public void test(){}
	
	public void setAtttributeByjson(JSONObject json){
		this.name = json.optString("name");
	}
	
	public JSONObject getJson(){
		return null;
	}
	
	public String checkNull(String params){
		if("null".equals(params))return "";
		return params;
	}	
}
