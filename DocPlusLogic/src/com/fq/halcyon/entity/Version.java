package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

public class Version extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	@Override
	public void test() {}
	
	private String versionName;
	private int versionCode;
	private int minCode;
	private String updateUrl;
	private String updateDes;
	
	public String getVersionName() {
		return versionName;
	}
	public void setVersionName(String versionName) {
		this.versionName = versionName;
	}
	public int getVersionCode() {
		return versionCode;
	}
	public void setVersionCode(int versionCode) {
		this.versionCode = versionCode;
	}
	public int getMinCode() {
		return minCode;
	}
	public void setMinCode(int minCode) {
		this.minCode = minCode;
	}
	public String getUpdateUrl() {
		return updateUrl;
	}
	public void setUpdateUrl(String updateUrl) {
		this.updateUrl = updateUrl;
	}

	public String getUpdateDes(){
		return this.updateDes;
	}
	
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.versionName = json.optString("version_name");
		this.versionCode = json.optInt("version_code");
		this.minCode = json.optInt("min_version_code");
		this.updateUrl = json.optString("update_url");
		this.updateDes = json.optString("update_des");
	}
}
