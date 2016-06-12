package com.fq.halcyon.entity;


import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

//"password":"1"

public class User extends Person {

	private static final long serialVersionUID = 1L;

	private String password;
	private String myInvition;
	private int dp_money;
	private int annual_fee;

	/**
	 * 设置是否仅wifi时上传病历</br> true：仅在有WIFI的时候长传病历</br> false：任何网络情况下都能上传病历</br>
	 */
	private boolean isOnlyWifi = false;
	/**
	 * 设置是否在wifi状态下自动下载并更新缓存所有病案和记录 true:是 false：否 默认为true
	 */
	private boolean isWifiAutoDownLoad = true;

	public void setDPMoney(int money) {
		this.dp_money = money;
	}

	public int getDPMoney() {
		return dp_money;
	}

	public void setAnnual(int annual) {
		annual_fee = annual;
	}

	public int getAnnual() {
		return annual_fee;
	}

	public String getInvition() {
		return myInvition;
	}

	public void setInvition(String invition) {
		this.myInvition = invition;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public boolean isOnlyWifi() {
		return isOnlyWifi;
	}

	public void setOnlyWifi(boolean isOnlyWifi) {
		this.isOnlyWifi = isOnlyWifi;
	}
	public boolean isWifiAutoDownLoad(){
		return isWifiAutoDownLoad;
	}
	
	public void setWifiAutoDownLoad(boolean isWifiAutoDownLoad){
		this.isWifiAutoDownLoad = isWifiAutoDownLoad;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.user_id = json.optInt("user_id");
		this.password = json.optString("password");
		this.dp_money = json.optInt("dp_money", -1);
		this.annual_fee = json.optInt("annual_fee", 0);
		this.myInvition = json.optString("invitation_code");
	}

	@Override
	public JSONObject getJson() {
		JSONObject json = super.getJson();
		try {
			json.put("password", password);
			json.put("dp_money", dp_money);
			json.put("annual_fee", annual_fee);
			json.put("invitation_code", myInvition);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json;
	}
}
