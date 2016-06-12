package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class Department extends HalcyonEntity{
	private static final long serialVersionUID = 1L;
	
	private int dept_id;
	private ArrayList<Department> child;
	private String dept_name;

	public boolean isHaveChild(){
		if(child == null || child.size() == 0){
			child = null;
			return false;	
		}
		return true;
	}
	
	
	public int getDepartmentId() {
		return dept_id;
	}

	public void setDepartmentId(int departmentId) {
		this.dept_id = departmentId;
	}

	public ArrayList<Department> getChild(){
		return child;
	}
	
	public String getName(){
		return dept_name;
	}
	
	public void setName(String name){
		dept_name = name;
	}
	
	
	@Override
	public void test() {
		
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.dept_id = json.optInt("dept_id");
		this.dept_name = json.optString("dept_name");
		JSONArray childs = json.optJSONArray("child");
		if(childs != null)
		{
			this.child = new ArrayList<Department>();
			for (int i = 0; i < childs.length(); i++) {
				Department de = new Department();
				de.setAtttributeByjson(childs.optJSONObject(i));
				child.add(de);
			}
		}
	}
}
