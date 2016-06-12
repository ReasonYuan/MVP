package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class City extends HalcyonEntity{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int id;
	private int city_type;
	private ArrayList<City> child;
	
	
	public int getType() {
		return city_type;
	}
	public void setType(int type) {
		this.city_type = type;
	}
	public int getCityId() {
		return id;
	}
	public void setCityId(int cityId) {
		this.id = cityId;
	}
	
	public void addChild(City city){
		if(child == null)child = new ArrayList<City>();
		child.add(city);
	}
	
	public boolean isHaveChild(){
		if(child == null)return false;
		else if(child.size() == 0){
			child = null;
			return false;
		}
		return true;
	}
	
	public ArrayList<City> getChildren(){
		return child;
	}
	
	public void setChildren(ArrayList<City> citys){
		child = citys;
	}
	
	
	@Override
	public void test() {
		
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.id = json.optInt("id");
		this.city_type = json.optInt("city_type");
		JSONArray childs = json.optJSONArray("child");
		if(childs != null)
		{
			this.child = new ArrayList<City>();
			for (int i = 0; i < childs.length(); i++) {
				City city = new City();
				city.setAtttributeByjson(childs.optJSONObject(i));
				child.add(city);
			}
		}
	}
}
